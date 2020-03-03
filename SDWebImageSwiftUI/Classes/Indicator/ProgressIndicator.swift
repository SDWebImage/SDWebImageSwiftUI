/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI

#if os(macOS) || os(iOS) || os(tvOS)
/// A progress bar indicator (system style)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ProgressIndicator: PlatformViewRepresentable {
    @Binding var isAnimating: Bool
    @Binding var progress: Double
    var style: Style
    
    /// Create indicator with animation binding, progress binding and the style
    /// - Parameters:
    ///   - isAnimating: The binding to control the animation
    ///   - progress: The binding to update the progress
    ///   - style: The indicator style
    public init(_ isAnimating: Binding<Bool>, progress: Binding<Double>, style: Style = .default) {
        self._isAnimating = isAnimating
        self._progress = progress
        self.style = style
    }
    
    #if os(macOS)
    public typealias NSViewType = ProgressIndicatorWrapper
    #elseif os(iOS) || os(tvOS)
    public typealias UIViewType = ProgressIndicatorWrapper
    #endif
    
    #if os(iOS) || os(tvOS)
    public func makeUIView(context: UIViewRepresentableContext<ProgressIndicator>) -> ProgressIndicatorWrapper {
        let progressStyle: UIProgressView.Style
        switch style {
        #if os(iOS)
        case .bar:
            progressStyle = .bar
        #endif
        case .default:
            progressStyle = .default
        }
        let uiView = ProgressIndicatorWrapper()
        let view = uiView.wrapped
        view.progressViewStyle = progressStyle
        return uiView
    }
    
    public func updateUIView(_ uiView: ProgressIndicatorWrapper, context: UIViewRepresentableContext<ProgressIndicator>) {
        let view = uiView.wrapped
        if isAnimating {
            view.setProgress(Float(progress), animated: true)
        } else {
            if progress == 0 {
                view.isHidden = false
                view.progress = 0
            } else {
                view.isHidden = true
                view.progress = 1
            }
        }
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> ProgressIndicatorWrapper {
        let nsView = ProgressIndicatorWrapper()
        let view = nsView.wrapped
        view.style = .bar
        view.isDisplayedWhenStopped = false
        view.controlSize = .small
        view.frame = CGRect(x: 0, y: 0, width: 160, height: 0) // Width from `UIProgressView` default width
        view.sizeToFit()
        view.autoresizingMask = [.maxXMargin, .minXMargin, .maxYMargin, .minYMargin]
        return nsView
    }
    
    public func updateNSView(_ nsView: ProgressIndicatorWrapper, context: NSViewRepresentableContext<ProgressIndicator>) {
        let view = nsView.wrapped
        if isAnimating {
            view.isIndeterminate = false
            view.doubleValue = Double(progress) * 100
            view.startAnimation(nil)
        } else {
            if progress == 0 {
                view.isHidden = false
                view.isIndeterminate = true
                view.doubleValue = 0
                view.stopAnimation(nil)
            } else {
                view.isHidden = true
                view.isIndeterminate = false
                view.doubleValue = 100
                view.stopAnimation(nil)
            }
        }
    }
    #endif
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ProgressIndicator {
    public enum Style {
        case `default`
        #if os(iOS)
        case bar
        #endif
    }
}
#endif
