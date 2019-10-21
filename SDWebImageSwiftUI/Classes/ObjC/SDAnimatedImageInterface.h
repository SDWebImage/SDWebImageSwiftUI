/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

@import SDWebImage;

#if SD_WATCH
NS_ASSUME_NONNULL_BEGIN

/// Do not use this class directly in WatchKit or Storyboard. This class is implementation detail and will be removed in the future.
@interface SDAnimatedImageInterface : WKInterfaceImage

- (instancetype)init WK_AVAILABLE_WATCHOS_ONLY(6.0);
- (void)setContentMode:(SDImageScaleMode)contentMode;
- (void)setAnimationRepeatCount:(nullable NSNumber *)repeatCount;

@end

NS_ASSUME_NONNULL_END
#endif
