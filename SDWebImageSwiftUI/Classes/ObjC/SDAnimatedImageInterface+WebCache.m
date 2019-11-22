/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterface+WebCache.h"
#import <objc/runtime.h>

@implementation SDAnimatedImageInterface (WebCache)

- (NSString *)sd_imageName {
    return objc_getAssociatedObject(self, @selector(sd_imageName));
}

- (void)setSd_imageName:(NSString *)sd_imageName {
    objc_setAssociatedObject(self, @selector(sd_imageName), sd_imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSData *)sd_imageData {
    return objc_getAssociatedObject(self, @selector(sd_imageData));
}

- (void)setSd_imageData:(NSData *)sd_imageData {
    objc_setAssociatedObject(self, @selector(sd_imageData), sd_imageData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
