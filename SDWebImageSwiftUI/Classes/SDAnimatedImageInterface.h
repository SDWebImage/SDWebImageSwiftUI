/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import <SDWebImage/SDWebImage.h>
#if SD_WATCH
@interface SDAnimatedImageInterface : WKInterfaceImage

- (instancetype)init WK_AVAILABLE_WATCHOS_ONLY(6.0);
- (void)setContentMode:(SDImageScaleMode)contentMode;

@end
#endif
