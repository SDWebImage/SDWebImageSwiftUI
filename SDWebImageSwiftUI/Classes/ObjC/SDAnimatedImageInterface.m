/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterface.h"
#if SD_WATCH
// ImageIO.modulemap does not contains this public header
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-umbrella"
#import <ImageIO/CGImageAnimation.h>
#pragma clang diagnostic pop

#pragma mark - SPI

#define kCGImageAnimationStatus_Uninitialized -1

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

@end

@interface WKInterfaceObject ()

// This is needed for dynamic created WKInterfaceObject, like `WKInterfaceMap`
- (instancetype)_initForDynamicCreationWithInterfaceProperty:(NSString *)property;
// This is remote UIView
@property (nonatomic, strong, readonly) id<UIViewProtocol> _interfaceView;

@end

@interface SDAnimatedImageStatus : NSObject

@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) CGImageAnimationStatus animationStatus;

@end

@implementation SDAnimatedImageStatus

- (instancetype)init {
    self = [super init];
    if (self) {
        _animationStatus = kCGImageAnimationStatus_Uninitialized;
    }
    return self;
}

@end

@interface SDAnimatedImageInterface () {
    UIImage *_image;
}

@property (nonatomic, strong, readwrite) UIImage *currentFrame;
@property (nonatomic, assign, readwrite) NSUInteger currentFrameIndex;
@property (nonatomic, assign, readwrite) NSUInteger currentLoopCount;
@property (nonatomic, assign) NSUInteger totalFrameCount;
@property (nonatomic, assign) NSUInteger totalLoopCount;
@property (nonatomic, strong) UIImage<SDAnimatedImage> *animatedImage;
@property (nonatomic, assign) CGFloat animatedImageScale;
@property (nonatomic, strong) SDAnimatedImageStatus *currentStatus;
@property (nonatomic, strong) NSNumber *animationRepeatCount;
@property (nonatomic, assign, getter=isAnimatedFormat) BOOL animatedFormat;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation SDAnimatedImageInterface

- (instancetype)init {
    Class cls = [self class];
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSString *property = [NSString stringWithFormat:@"%@_%@", cls, UUID];
    self = [self _initForDynamicCreationWithInterfaceProperty:property];
    return self;
}

- (NSDictionary *)interfaceDescriptionForDynamicCreation {
    // This is called by WatchKit
    return @{
        @"type" : @"image",
        @"property" : self.interfaceProperty,
        @"image" : [self.class sharedEmptyImage]
    };
}

+ (UIImage *)sharedEmptyImage {
    // This is used for placeholder on `WKInterfaceImage`
    // Do not using `[UIImage new]` because WatchKit will ignore it
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        UIColor *color = UIColor.clearColor;
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)setImage:(UIImage *)image {
    if (_image == image) {
        return;
    }
    _image = image;
    
    // Stop animating
    [self stopBuiltInAnimation];
    // Reset all value
    [self resetAnimatedImage];
    
    [super setImage:image];
    if ([image.class conformsToProtocol:@protocol(SDAnimatedImage)]) {
        UIImage<SDAnimatedImage> *animatedImage = (UIImage<SDAnimatedImage> *)image;
        NSUInteger animatedImageFrameCount = animatedImage.animatedImageFrameCount;
        // Check the frame count
        if (animatedImageFrameCount <= 1) {
            return;
        }
        self.animatedImage = animatedImage;
        self.totalFrameCount = animatedImageFrameCount;
        // Get the current frame and loop count.
        self.totalLoopCount = self.animatedImage.animatedImageLoopCount;
        // Get the scale
        self.animatedImageScale = image.scale;

        NSData *animatedImageData = animatedImage.animatedImageData;
        SDImageFormat format = [NSData sd_imageFormatForImageData:animatedImageData];
        if (format == SDImageFormatGIF || format == SDImageFormatPNG) {
            self.animatedFormat = YES;
            [self startBuiltInAnimation];
        } else {
            self.animatedFormat = NO;
            [self stopBuiltInAnimation];
        }
    }
}

- (void)updateAnimation {
    [self updateShouldAnimate];
    if (self.currentStatus.shouldAnimate) {
        [self startBuiltInAnimation];
    } else {
        [self stopBuiltInAnimation];
    }
}

- (void)startBuiltInAnimation {
    if (self.currentStatus && self.currentStatus.animationStatus == 0) {
        return;
    }
    UIImage<SDAnimatedImage> *animatedImage = self.animatedImage;
    NSData *animatedImageData = animatedImage.animatedImageData;
    NSUInteger maxLoopCount;
    if (self.animationRepeatCount != nil) {
        maxLoopCount = self.animationRepeatCount.unsignedIntegerValue;
    } else {
        maxLoopCount = animatedImage.animatedImageLoopCount;
    }
    if (maxLoopCount == 0) {
        // The documentation says `kCFNumberPositiveInfinity may be used`, but it actually treat as 1 loop count
        // 0 was treated as 1 loop count as well, not the same as Image/IO or UIKit
        maxLoopCount = ((__bridge NSNumber *)kCFNumberPositiveInfinity).unsignedIntegerValue - 1;
    }
    NSDictionary *options = @{(__bridge NSString *)kCGImageAnimationLoopCount : @(maxLoopCount)};
    SDAnimatedImageStatus *status = [[SDAnimatedImageStatus alloc] init];
    status.shouldAnimate = YES;
    __weak typeof(self) wself = self;
    status.animationStatus = CGAnimateImageDataWithBlock((__bridge CFDataRef)animatedImageData, (__bridge CFDictionaryRef)options, ^(size_t index, CGImageRef  _Nonnull imageRef, bool * _Nonnull stop) {
        __strong typeof(wself) self = wself;
        if (!self) {
            *stop = YES;
            return;
        }
        if (!status.shouldAnimate) {
            *stop = YES;
            return;
        }
        // The CGImageRef provided by this API is GET only, should not call CGImageRelease
        self.currentFrame = [[UIImage alloc] initWithCGImage:imageRef scale:self.animatedImageScale orientation:UIImageOrientationUp];
        self.currentFrameIndex = index;
        // Render the frame
        [self displayLayer];
    });
    
    self.currentStatus = status;
}

- (void)stopBuiltInAnimation {
    self.currentStatus.shouldAnimate = NO;
    self.currentStatus.animationStatus = kCGImageAnimationStatus_Uninitialized;
}

- (void)displayLayer {
    if (self.currentFrame) {
        id<CALayerProtocol> layer = [self _interfaceView].layer;
        layer.contentsScale = self.animatedImageScale;
        layer.contents = (__bridge id)self.currentFrame.CGImage;
    }
}

- (void)resetAnimatedImage
{
    self.animatedImage = nil;
    self.totalFrameCount = 0;
    self.totalLoopCount = 0;
    self.currentFrame = nil;
    self.currentFrameIndex = 0;
    self.currentLoopCount = 0;
    self.animatedImageScale = 1;
    self.animatedFormat = NO;
    self.currentStatus = nil;
}

- (void)updateShouldAnimate
{
    id<UIViewProtocol> view = [self _interfaceView];
    BOOL isVisible = view.window && view.superview && ![view isHidden] && view.alpha > 0.0;
    self.currentStatus.shouldAnimate = self.isAnimating && self.animatedImage && self.isAnimatedFormat && self.totalFrameCount > 1 && isVisible;
}

- (void)startAnimating {
    self.animating = YES;
    if (self.animatedImage) {
        [self startBuiltInAnimation];
    } else if (_image.images.count > 0) {
        [super startAnimating];
    }
}

- (void)startAnimatingWithImagesInRange:(NSRange)imageRange duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount {
    self.animating = YES;
    if (self.animatedImage) {
        [self startBuiltInAnimation];
    } else if (_image.images.count > 0) {
        [super startAnimatingWithImagesInRange:imageRange duration:duration repeatCount:repeatCount];
    }
}

- (void)stopAnimating {
    self.animating = NO;
    if (self.animatedImage) {
        [self stopBuiltInAnimation];
    } else if (_image.images.count > 0) {
        [super stopAnimating];
    }
}

- (void)setContentMode:(SDImageScaleMode)contentMode {
    [self _interfaceView].contentMode = contentMode;
}

@end

#pragma mark - Web Cache

@interface SDAnimatedImageInterface (WebCache)

@end

@implementation SDAnimatedImageInterface (WebCache)

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                   context:(nullable SDWebImageContext *)context
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    Class animatedImageClass = [SDAnimatedImage class];
    SDWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[SDWebImageContextAnimatedImageClass] = animatedImageClass;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
    }];
}

@end
#endif
