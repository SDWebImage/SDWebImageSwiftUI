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
/// This is not public API at all.
@interface SDAnimatedImageInterface : WKInterfaceImage

@property (nonatomic, assign, getter=isAnimating, readonly) BOOL animating;
@property (nonatomic, assign) SDImageScaleMode contentMode;
@property (nonatomic, strong, nullable) NSNumber *animationRepeatCount;
@property (nonatomic, copy) NSRunLoopMode runLoopMode;
@property (nonatomic, assign) BOOL resetFrameIndexWhenStopped;
@property (nonatomic, assign) BOOL clearBufferWhenStopped;
@property (nonatomic, assign) double playbackRate;

- (instancetype)init WK_AVAILABLE_WATCHOS_ONLY(6.0);

/// Trigger the animation check when view appears/disappears
- (void)updateAnimation;

@end

NS_ASSUME_NONNULL_END
#endif
