/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension Image {
    @inlinable init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension PlatformImage {
    static var empty = PlatformImage()
}

#if !os(macOS)
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension PlatformImage.Orientation {
    @inlinable var toSwiftUI: Image.Orientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension Image.Orientation {
    @inlinable var toPlatform: PlatformImage.Orientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        }
    }
}
#endif
