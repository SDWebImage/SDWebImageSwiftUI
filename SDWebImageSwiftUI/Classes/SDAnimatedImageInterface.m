/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterface.h"
#import <SDWebImage/SDWebImage.h>
#import <ImageIO/CGImageAnimation.h>

@protocol CALayerProtocol <NSObject>
@property (nullable, strong) id contents;
@property CGFloat contentsScale;
@end

@protocol UIViewProtocol <NSObject>
@property (nonatomic, strong, readonly) id<CALayerProtocol> layer;
@property (nonatomic, assign) SDImageScaleMode contentMode;
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

@end

@implementation SDAnimatedImageInterface

- (instancetype)init {
    Class cls = [self class];
    NSString *UUID = [NSUUID UUID].UUIDString;
    NSString *property = [NSString stringWithFormat:@"%@_%@", cls, UUID];
    self = [self _initForDynamicCreationWithInterfaceProperty:property];
    return self;
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

-(NSDictionary *)interfaceDescriptionForDynamicCreation {
    return @{
        @"type" : @"image",
        @"property" : self.interfaceProperty,
        @"image" : [self.class sharedEmptyImage]
    };
}

- (void)setImage:(UIImage *)image {
    if (_image == image) {
        return;
    }
    _image = image;
    
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
            [self startBuiltInAnimationWithImage:animatedImage];
        }
        
        // Update should animate
        [self updateShouldAnimate];
    }
}

- (void)startBuiltInAnimationWithImage:(UIImage<SDAnimatedImage> *)animatedImage {
    NSData *animatedImageData = animatedImage.animatedImageData;
    NSUInteger maxLoopCount = 0;
    if (maxLoopCount == 0) {
        // The documentation says `kCFNumberPositiveInfinity may be used`, but it actually treat as 1 loop count
        // 0 was treated as 1 loop count as well, not the same as Image/IO or UIKit
        maxLoopCount = ((__bridge NSNumber *)kCFNumberPositiveInfinity).unsignedIntegerValue - 1;
    }
    NSDictionary *options = @{(__bridge NSString *)kCGImageAnimationLoopCount : @(maxLoopCount)};
    SDAnimatedImageStatus *status = [SDAnimatedImageStatus new];
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
    // reset current state
    self.currentStatus.shouldAnimate = NO;
    self.currentStatus = nil;
    [self resetCurrentFrameIndex];
    self.animatedImageScale = 1;
}

- (void)resetCurrentFrameIndex
{
    self.currentFrame = nil;
    self.currentFrameIndex = 0;
    self.currentLoopCount = 0;
}

- (void)updateShouldAnimate
{
    self.currentStatus.shouldAnimate = self.animatedImage && self.totalFrameCount > 1;
}

- (void)startAnimating {
    if (self.animatedImage) {
        self.currentStatus.shouldAnimate = YES;
    } else if (_image.images.count > 0) {
        [super startAnimating];
    }
}

- (void)startAnimatingWithImagesInRange:(NSRange)imageRange duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount {
    if (self.animatedImage) {
        self.currentStatus.shouldAnimate = YES;
    } else if (_image.images.count > 0) {
        [super startAnimatingWithImagesInRange:imageRange duration:duration repeatCount:repeatCount];
    }
}

- (void)stopAnimating {
    if (self.animatedImage) {
        self.currentStatus.shouldAnimate = YES;
    } else if (_image.images.count > 0) {
        [super stopAnimating];
    }
}

- (void)setContentMode:(SDImageScaleMode)contentMode {
    [self _interfaceView].contentMode = contentMode;
}

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
