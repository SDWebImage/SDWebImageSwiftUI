/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import SwiftUI
@_exported import SDWebImage // Automatically import SDWebImage

#if os(macOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformImage = NSImage
#else
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformImage = UIImage
#endif

#if os(macOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformView = NSView
#endif
#if os(iOS) || os(tvOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformView = UIView
#endif
#if os(watchOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformView = WKInterfaceObject
#endif

#if os(macOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformViewRepresentable = NSViewRepresentable
#endif
#if os(iOS) || os(tvOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformViewRepresentable = UIViewRepresentable
#endif
#if os(watchOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias PlatformViewRepresentable = WKInterfaceObjectRepresentable
#endif

#if os(macOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension NSViewRepresentable {
    typealias PlatformViewType = NSViewType
}
#endif
#if os(iOS) || os(tvOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension UIViewRepresentable {
    typealias PlatformViewType = UIViewType
}
#endif
#if os(watchOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WKInterfaceObjectRepresentable {
    typealias PlatformViewType = WKInterfaceObjectType
}
#endif
