/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

/// A  type to build the indicator
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Indicator<T> where T : View {
    var content: (Binding<Bool>, Binding<Double>) -> T
    
    /// Create a indicator with builder
    /// - Parameter builder: A builder to build indicator
    /// - Parameter isAnimating: A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
    /// - Parameter progress: A Binding to control the progress during loading. Value between [0.0, 1.0]. If no progress can be reported, the value is 0.
    /// Associate a indicator when loading image with url
    public init(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<Double>) -> T) {
        self.content = content
    }
}

/// A protocol to report indicator progress
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol IndicatorReportable : ObservableObject {
    /// whether indicator is loading or not
    var isLoading: Bool { get set }
    /// indicator progress, should only be used for indicator binding, value between [0.0, 1.0]
    var progress: Double { get set }
}

/// A implementation detail View Modifier with indicator
/// SwiftUI View Modifier construced by using a internal View type which modify the `body`
/// It use type system to represent the view hierarchy, and Swift `some View` syntax to hide the type detail for users
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct IndicatorViewModifier<T, V> : ViewModifier where T : View, V : IndicatorReportable {
    
    /// The progress reporter
    @ObservedObject public var reporter: V
    
    /// The indicator
    public var indicator: Indicator<T>
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if reporter.isLoading {
                indicator.content($reporter.isLoading, $reporter.progress)
            }
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Indicator where T == ActivityIndicator {
    /// Activity Indicator
    public static var activity: Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating)
        }
    }
    
    /// Activity Indicator with style
    /// - Parameter style: style
    public static func activity(style: ActivityIndicator.Style) -> Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating, style: style)
        }
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Indicator where T == ProgressIndicator {
    /// Progress Indicator
    public static var progress: Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress)
        }
    }
    
    /// Progress Indicator with style
    /// - Parameter style: style
    public static func progress(style: ProgressIndicator.Style) -> Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress, style: style)
        }
    }
}
#endif
