/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI
import Combine

/// A  type to build the indicator
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
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

/// A observable model to report indicator loading status
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
public class IndicatorStatus : ObservableObject {
    /// whether indicator is loading or not
    var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    /// indicator progress, should only be used for indicator binding, value between [0.0, 1.0]
    var progress: Double = 0 {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
}

/// A implementation detail View Modifier with indicator
/// SwiftUI View Modifier construced by using a internal View type which modify the `body`
/// It use type system to represent the view hierarchy, and Swift `some View` syntax to hide the type detail for users
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
public struct IndicatorViewModifier<T> : ViewModifier where T : View {
    
    /// The loading status
    @ObservedObject public var status: IndicatorStatus
    
    /// The indicator
    public var indicator: Indicator<T>
    
    @ViewBuilder
    private var overlay: some View {
        if status.isLoading {
            indicator.content($status.isLoading, $status.progress)
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            overlay
        }
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension Indicator where T == AnyView {
    /// Activity Indicator
    public static var activity: Indicator<T> {
        Indicator { isAnimating, _ in
            AnyView(ProgressView().opacity(isAnimating.wrappedValue ? 1 : 0))
        }
    }
    
    /// Activity Indicator with style
    /// - Parameter style: style
    public static func activity<S>(style: S) -> Indicator<T> where S: ProgressViewStyle {
        Indicator { isAnimating, _ in
            AnyView(ProgressView().progressViewStyle(style).opacity(isAnimating.wrappedValue ? 1 : 0))
        }
    }
}

@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension Indicator where T == AnyView {
    /// Progress Indicator
    public static var progress: Indicator<T> {
        Indicator { isAnimating, progress in
            AnyView(ProgressView(value: progress.wrappedValue).opacity(isAnimating.wrappedValue ? 1 : 0))
        }
    }
    
    /// Progress Indicator with style
    /// - Parameter style: style
    public static func progress<S>(style: S) -> Indicator<T> where S: ProgressViewStyle {
        Indicator { isAnimating, progress in
            AnyView(ProgressView(value: progress.wrappedValue).progressViewStyle(style).opacity(isAnimating.wrappedValue ? 1 : 0))
        }
    }
}
