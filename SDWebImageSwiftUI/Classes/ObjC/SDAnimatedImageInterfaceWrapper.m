/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterfaceWrapper.h"
#if SD_WATCH
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - SPI

@protocol CALayerProtocol <NSObject>
@property (nullable, strong) id contents;
@property CGFloat contentsScale;
@end

@protocol UIViewProtocol <NSObject>
@property (nonatomic, strong, readonly) id<CALayerProtocol> layer;
@property (nonatomic, assign) SDImageScaleMode contentMode;
@property (nonatomic, readonly) id<UIViewProtocol> superview;
@property (nonatomic, readonly, copy) NSArray<id<UIViewProtocol>> *subviews;
@property (nonatomic, readonly) id window;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, getter=isOpaque) BOOL opaque;
@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGPoint center;
@property (nonatomic, readonly) CGSize intrinsicContentSize;
@property(nonatomic) NSInteger tag;

- (void)invalidateIntrinsicContentSize;
- (void)layoutSubviews;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;

@end

@protocol UIImageViewProtocol <UIViewProtocol>

@property (nullable, nonatomic, strong) UIImage *image;
- (void)startAnimating;
- (void)stopAnimating;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

@interface WKInterfaceObject ()

// This is needed for dynamic created WKInterfaceObject, like `WKInterfaceMap`
- (instancetype)_initForDynamicCreationWithInterfaceProperty:(NSString *)property;
- (NSDictionary *)interfaceDescriptionForDynamicCreation;
// This is remote UIView
@property (nonatomic, strong, readwrite) id<UIViewProtocol> _interfaceView;

@end

#define SDAnimatedImageInterfaceWrapperTag 123456789
#define SDAnimatedImageInterfaceWrapperSEL_layoutSubviews @"SDAnimatedImageInterfaceWrapper_layoutSubviews"
#define SDAnimatedImageInterfaceWrapperSEL_sizeThatFits @" SDAnimatedImageInterfaceWrapper_sizeThatFits:"

// This using hook to implements the same logic like AnimatedImageViewWrapper.swift
static CGSize intrinsicContentSizeIMP(id<UIViewProtocol> self, SEL _cmd) {
    struct objc_super superClass = {
       self,
       [self superclass]
    };
    NSUInteger tag = self.tag;
    id<UIViewProtocol> interfaceView = self.subviews.firstObject;
    if (tag != SDAnimatedImageInterfaceWrapperTag || !interfaceView) {
        return ((CGSize(*)(id, SEL))objc_msgSendSuper)((__bridge id)(&superClass), _cmd);
    }
    CGSize size = interfaceView.intrinsicContentSize;
    if (size.width > 0 && size.height > 0) {
        CGFloat aspectRatio = size.height / size.width;
        return CGSizeMake(1, 1 * aspectRatio);
    } else {
        return CGSizeMake(-1, -1);
    }
}

static void layoutSubviewsIMP(id<UIViewProtocol> self, SEL _cmd) {
    struct objc_super superClass = {
       self,
       [self superclass]
    };
    NSUInteger tag = self.tag;
    id<UIViewProtocol> interfaceView = self.subviews.firstObject;
    if (tag != SDAnimatedImageInterfaceWrapperTag || !interfaceView) {
        ((void(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(SDAnimatedImageInterfaceWrapperSEL_layoutSubviews));
        return;
    }
    ((void(*)(id, SEL))objc_msgSendSuper)((__bridge id)(&superClass), _cmd);
    interfaceView.frame = self.bounds;
}

// This is suck that SwiftUI on watchOS will call extra sizeThatFits, we should always return input size (already calculated with aspectRatio)
// iOS's wrapper don't need this. Apple should provide the public API on View protocol to specify `intrinsicContentSize` or `intrinsicAspectRatio`
static CGSize sizeThatFitsIMP(id<UIViewProtocol> self, SEL _cmd, CGSize size) {
    NSUInteger tag = self.tag;
    id<UIViewProtocol> interfaceView = self.subviews.firstObject;
    if (tag != SDAnimatedImageInterfaceWrapperTag || !interfaceView) {
        return ((CGSize(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(SDAnimatedImageInterfaceWrapperSEL_sizeThatFits));
    }
    return size;
}

@implementation SDAnimatedImageInterfaceWrapper

/// Use wrapper to solve tne watchOS `WKInterfaceImage` frame size become image size issue, as well as aspect ratio issue (SwiftUI's Bug)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"SPInterfaceGroupView");
        // Implements `intrinsicContentSize`
        SEL selector = @selector(intrinsicContentSize);
        Method method = class_getInstanceMethod(class, selector);

        BOOL didAddMethod =
            class_addMethod(class,
                selector,
                (IMP)intrinsicContentSizeIMP,
                method_getTypeEncoding(method));
        if (!didAddMethod) {
            NSAssert(NO, @"SDAnimatedImageInterfaceWrapper will not work as expected.");
        }
        
        // Override `layoutSubviews`
        SEL originalSelector = @selector(layoutSubviews);
        SEL swizzledSelector = NSSelectorFromString(SDAnimatedImageInterfaceWrapperSEL_layoutSubviews);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        
        didAddMethod =
        class_addMethod(class,
            swizzledSelector,
            (IMP)layoutSubviewsIMP,
            method_getTypeEncoding(originalMethod));
        if (!didAddMethod) {
            NSAssert(NO, @"SDAnimatedImageInterfaceWrapper will not work as expected.");
        } else {
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        // Override `sizeThatFits:`
        originalSelector = @selector(sizeThatFits:);
        swizzledSelector = NSSelectorFromString(SDAnimatedImageInterfaceWrapperSEL_sizeThatFits);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        
        didAddMethod =
        class_addMethod(class,
            swizzledSelector,
            (IMP)sizeThatFitsIMP,
            method_getTypeEncoding(originalMethod));
        if (!didAddMethod) {
            NSAssert(NO, @"SDAnimatedImageInterfaceWrapper will not work as expected.");
        } else {
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (instancetype)init {
    Class cls = [self class];
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSString *property = [NSString stringWithFormat:@"%@_%@", cls, UUID];
    self = [self _initForDynamicCreationWithInterfaceProperty:property];
    if (self) {
        self.wrapped = [[SDAnimatedImageInterface alloc] init];
    }
    return self;
}

- (NSDictionary *)interfaceDescriptionForDynamicCreation {
    // This is called by WatchKit to provide default value
    return @{
        @"type" : @"group",
        @"property" : self.interfaceProperty,
        @"radius" : @(0),
        @"items": @[self.wrapped.interfaceDescriptionForDynamicCreation], // This will create the native view and added to subview
    };
}

- (void)set_interfaceView:(id<UIViewProtocol>)interfaceView {
    // This is called by WatchKit when native view created
    [super set_interfaceView:interfaceView];
    // Bind the interface object and native view
    interfaceView.tag = SDAnimatedImageInterfaceWrapperTag;
    self.wrapped._interfaceView = interfaceView.subviews.firstObject;
}

- (void)invalidateIntrinsicContentSize {
    [self._interfaceView invalidateIntrinsicContentSize];
}

@end

#endif
