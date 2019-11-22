/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "SDAnimatedImageInterface.h"

#if SD_WATCH
NS_ASSUME_NONNULL_BEGIN

/// Do not use this class directly in WatchKit or Storyboard. This class is implementation detail and will be removed in the future.
/// This is not public API at all.
@interface SDAnimatedImageInterface (WebCache)

@property (nonatomic, strong, nullable) NSString *sd_imageName;
@property (nonatomic, strong, nullable) NSData *sd_imageData;

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                   context:(nullable SDWebImageContext *)context
                  progress:(nullable SDImageLoaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
#endif
