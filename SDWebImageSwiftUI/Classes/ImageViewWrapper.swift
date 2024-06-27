/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SDWebImage
import SwiftUI

#if !os(watchOS)

/// Use wrapper to solve tne `UIImageView`/`NSImageView` frame size become image size issue (SwiftUI's Bug)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public class AnimatedImageViewWrapper : PlatformView {
    /// The wrapped actual image view, using SDWebImage's aniamted image view
    public var wrapped = SDAnimatedImageView()
    var interpolationQuality = CGInterpolationQuality.default
    var shouldAntialias = false
    var resizingMode: Image.ResizingMode?
    
    public override func draw(_ rect: CGRect) {
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
        let imageSize = wrapped.intrinsicContentSize
        if let _ = resizingMode {
            /// Keep aspect ratio
            let noIntrinsicMetric = AnimatedImageViewWrapper.noIntrinsicMetric
            if (imageSize.width > 0 && imageSize.height > 0) {
                let ratio = imageSize.width / imageSize.height
                let size = CGSize(width: ratio, height: 1)
                return size
            } else {
                return CGSize(width: noIntrinsicMetric, height: noIntrinsicMetric)
            }
        } else {
            /// Not resizable, always use image size, like SwiftUI.Image
            return imageSize
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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
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
}

#endif
