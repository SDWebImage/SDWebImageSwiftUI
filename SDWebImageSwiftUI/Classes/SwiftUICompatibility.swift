/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import Foundation
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS)

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct PlatformAppear: PlatformViewRepresentable {
    let appearAction: () -> Void
    let disappearAction: () -> Void
    
    #if os(iOS) || os(tvOS)
    func makeUIView(context: Context) -> some UIView {
        let view = PlatformAppearView()
        view.appearAction = appearAction
        view.disappearAction = disappearAction
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    #endif
    #if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        let view = PlatformAppearView()
        view.appearAction = appearAction
        view.disappearAction = disappearAction
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
    #endif
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
class PlatformAppearView: PlatformView {
    var appearAction: () -> Void = {}
    var disappearAction: () -> Void = {}
    
    #if os(iOS) || os(tvOS)
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            DispatchQueue.main.async {
                self.appearAction()
            }
        } else {
            DispatchQueue.main.async {
                self.disappearAction()
            }
        }
    }
    #endif
    
    #if os(macOS)
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow != nil {
            DispatchQueue.main.async {
                self.appearAction()
            }
        } else {
            DispatchQueue.main.async {
                self.disappearAction()
            }
        }
    }
    #endif
}

#endif

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    /// Used UIKit/AppKit behavior to detect the SwiftUI view's visibility.
    /// This hack is because of SwiftUI 1.0/2.0 buggy behavior. The built-in `onAppear` and `onDisappear` is so massive on some cases. Where UIKit/AppKit is solid.
    /// - Parameters:
    ///   - appear: The action when view appears
    ///   - disappear: The action when view disappears
    /// - Returns: Some view
    func onPlatformAppear(appear: @escaping () -> Void = {}, disappear: @escaping () -> Void = {}) -> some View {
        #if os(iOS) || os(tvOS) || os(macOS)
        return self.background(PlatformAppear(appearAction: appear, disappearAction: disappear))
        #else
        return self.onAppear(perform: appear).onDisappear(perform: disappear)
        #endif
    }
}
