/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterface.h"
#if SD_WATCH

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

@protocol UIImageViewProtocol <NSObject>

- (void)startAnimating;
- (void)stopAnimating;
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

@interface WKInterfaceObject ()

// This is needed for dynamic created WKInterfaceObject, like `WKInterfaceMap`
- (instancetype)_initForDynamicCreationWithInterfaceProperty:(NSString *)property;
// This is remote UIView
@property (nonatomic, strong, readonly) id<UIViewProtocol> _interfaceView;

@end

@interface SDAnimatedImageInterface () {
    UIImage *_image;
}

@property (nonatomic, strong, readwrite) UIImage *currentFrame;
@property (nonatomic, assign, readwrite) NSUInteger currentFrameIndex;
@property (nonatomic, assign, readwrite) NSUInteger currentLoopCount;
@property (nonatomic, strong) NSNumber *animationRepeatCount;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, copy) NSRunLoopMode runLoopMode;
@property (nonatomic, assign) double playbackRate;
@property (nonatomic,strong) SDAnimatedImagePlayer *player; // The animation player.
@property (nonatomic) id<CALayerProtocol> imageViewLayer; // The actual rendering layer.

@end

@implementation SDAnimatedImageInterface

- (instancetype)init {
    Class cls = [self class];
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSString *property = [NSString stringWithFormat:@"%@_%@", cls, UUID];
    self = [self _initForDynamicCreationWithInterfaceProperty:property];
    if (self) {
        self.runLoopMode = NSRunLoopCommonModes;
        self.playbackRate = 1.0;
    }
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
    self.player = nil;
    self.currentFrame = nil;
    self.currentFrameIndex = 0;
    self.currentLoopCount = 0;
    
    [super setImage:image];
    if ([image.class conformsToProtocol:@protocol(SDAnimatedImage)]) {
        // Create animted player
        self.player = [SDAnimatedImagePlayer playerWithProvider:(id<SDAnimatedImage>)image];
        
        if (!self.player) {
            // animated player nil means the image format is not supported, or frame count <= 1
            return;
        }
        
        // Custom Loop Count
        if (self.animationRepeatCount != nil) {
            self.player.totalLoopCount = self.animationRepeatCount.unsignedIntegerValue;
        }
        
        // RunLoop Mode
        self.player.runLoopMode = self.runLoopMode;

        // Play Rate
        self.player.playbackRate = self.playbackRate;
        
        // Setup handler
        __weak typeof(self) wself = self;
        self.player.animationFrameHandler = ^(NSUInteger index, UIImage * frame) {
            __strong typeof(self) sself = wself;
            sself.currentFrameIndex = index;
            sself.currentFrame = frame;
            [sself displayLayer:sself.imageViewLayer];
        };
        self.player.animationLoopHandler = ^(NSUInteger loopCount) {
            __strong typeof(self) sself = wself;
            sself.currentLoopCount = loopCount;
        };
        
        // Update should animate
        [self updateShouldAnimate];
        if (self.shouldAnimate) {
            [self startAnimating];
        }
        
        [self displayLayer:self.imageViewLayer];
    }
}

- (void)updateAnimation {
    [self updateShouldAnimate];
    if (self.shouldAnimate) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)displayLayer:(id<CALayerProtocol>)layer {
    UIImage *currentFrame = self.currentFrame;
    if (currentFrame) {
        layer.contentsScale = currentFrame.scale;
        layer.contents = (__bridge id)currentFrame.CGImage;
    }
}

// on watchOS, it's the native imageView itself's layer
- (id<CALayerProtocol>)imageViewLayer {
    return [[self _interfaceView] layer];
}

- (void)updateShouldAnimate
{
    id<UIViewProtocol> view = [self _interfaceView];
    BOOL isVisible = view.window && view.superview && ![view isHidden] && view.alpha > 0.0;
    self.shouldAnimate = self.player && isVisible;
}

- (BOOL)isAnimating
{
    if (self.player) {
        return self.player.isPlaying;
    } else {
        id<UIImageViewProtocol> view = (id<UIImageViewProtocol>)[self _interfaceView];
        return [view isAnimating];
    }
}

- (void)startAnimating {
    if (self.player) {
        [self.player startPlaying];
    } else if (_image.images.count > 0) {
        [super startAnimating];
    }
}

- (void)startAnimatingWithImagesInRange:(NSRange)imageRange duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount {
    if (self.player) {
        [self.player startPlaying];
    } else if (_image.images.count > 0) {
        [super startAnimatingWithImagesInRange:imageRange duration:duration repeatCount:repeatCount];
    }
}

- (void)stopAnimating {
    if (self.player) {
        [self.player stopPlaying];
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
