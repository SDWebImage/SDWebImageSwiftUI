//
//  SDAnimatedImageInterface.h
//  SDWebImageSwiftUI
//
//  Created by lizhuoli on 2019/10/6.
//  Copyright © 2019 SDWebImage. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAnimatedImageInterface : WKInterfaceImage

- (instancetype)init WK_AVAILABLE_WATCHOS_ONLY(6.0);
- (void)setContentMode:(SDImageScaleMode)contentMode;

@end

NS_ASSUME_NONNULL_END
