/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Swift
import SwiftUI

public struct ActivityIndicator: PlatformViewRepresentable {
    @Binding var isAnimating: Bool
    
    public init(_ isAnimating: Binding<Bool> = .constant(true)) {
        self._isAnimating = isAnimating
    }
    
    #if os(macOS)
    public typealias NSViewType = NSProgressIndicator
    #elseif os(iOS) || os(tvOS)
    public typealias UIViewType = UIActivityIndicatorView
    #endif
    
    #if os(iOS) || os(tvOS)
    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.isDisplayedWhenStopped = false
        return indicator
    }
    
    public func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
    }
    
    #endif
}
