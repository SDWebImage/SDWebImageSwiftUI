//
//  SDAnimatedImageInterface.h
//  SDWebImageSwiftUI
//
//  Created by lizhuoli on 2019/10/6.
//  Copyright © 2019 SDWebImage. All rights reserved.
//

#import <WatchKit/WatchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDAnimatedImageInterface : WKInterfaceImage

- (instancetype)init WK_AVAILABLE_WATCHOS_ONLY(6.0);

@end

NS_ASSUME_NONNULL_END
