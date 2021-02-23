/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SDWebImage

#if os(iOS) || os(tvOS) || os(macOS)

/// Use wrapper to solve tne `UIImageView`/`NSImageView` frame size become image size issue (SwiftUI's Bug)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class AnimatedImageViewWrapper : PlatformView {
    var wrapped = SDAnimatedImageView()
    var interpolationQuality = CGInterpolationQuality.default
    var shouldAntialias = false
    var resizable = false
    
    override public func draw(_ rect: CGRect) {
        #if os(macOS)
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }
        #else
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        #endif
        ctx.interpolationQuality = interpolationQuality
        ctx.setShouldAntialias(shouldAntialias)
    }
    
    #if os(macOS)
    public override func layout() {
        super.layout()
        wrapped.frame = self.bounds
    }
    #else
    public override func layoutSubviews() {
        super.layoutSubviews()
        wrapped.frame = self.bounds
    }
    #endif
    
    public override var intrinsicContentSize: CGSize {
        /// Match the behavior of SwiftUI.Image, only when image is resizable, use the super implementation to calculate size
        if resizable {
            return super.intrinsicContentSize
        } else {
            /// Not resizable, always use image size, like SwiftUI.Image
            return wrapped.intrinsicContentSize
        }
    }
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        addSubview(wrapped)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(wrapped)
    }
}

/// Use wrapper to solve the `UIProgressView`/`NSProgressIndicator` frame origin NaN crash (SwiftUI's bug)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class ProgressIndicatorWrapper : PlatformView {
    #if os(macOS)
    var wrapped = NSProgressIndicator()
    #else
    var wrapped = UIProgressView(progressViewStyle: .default)
    #endif
    
    #if os(macOS)
    public override func layout() {
        super.layout()
        wrapped.setFrameOrigin(CGPoint(x: round(self.bounds.width - wrapped.frame.width) / 2, y: round(self.bounds.height - wrapped.frame.height) / 2))
    }
    #else
    public override func layoutSubviews() {
        super.layoutSubviews()
        wrapped.center = self.center
    }
    #endif
    
    public override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        addSubview(wrapped)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(wrapped)
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension PlatformView {
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
    
    /// Finding the HostingView for UIKit/AppKit View.
    /// - Parameter entry: The entry platform view
    /// - Returns: The hosting view.
    func findHostingView() -> PlatformView? {
        var superview = self.superview
        while let s = superview {
            if NSStringFromClass(type(of: s)).contains("HostingView") {
                return s
            }
            superview = s.superview
        }
        return nil
    }
}

#endif
