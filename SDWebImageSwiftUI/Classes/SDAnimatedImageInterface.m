//
//  SDAnimatedImageInterface.m
//  SDWebImageSwiftUI
//
//  Created by lizhuoli on 2019/10/6.
//  Copyright © 2019 SDWebImage. All rights reserved.
//

#import "SDAnimatedImageInterface.h"
#import <SDWebImage/SDWebImage.h>
#import <ImageIO/CGImageAnimation.h>

// This is needed for dynamic created WKInterfaceObject, like `WKInterfaceMap`
@interface WKInterfaceObject ()

- (instancetype)_initForDynamicCreationWithInterfaceProperty:(NSString *)property;

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

-(NSDictionary *)interfaceDescriptionForDynamicCreation {
    return @{
        @"type" : @"image",
        @"property" : self.interfaceProperty,
        @"contentMode" : @(1), // UIViewContentModeScaleAspectFit
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
        [self display];
    });
    
    self.currentStatus = status;
}

- (void)display {
    [super setImage:self.currentFrame];
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
