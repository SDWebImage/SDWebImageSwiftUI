/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SDWebImage

#if !os(watchOS)

/// Use wrapper to solve tne `UIImageView`/`NSImageView` frame size become image size issue (SwiftUI's Bug)
public class AnimatedImageViewWrapper : PlatformView {
    var wrapped = SDAnimatedImageView()
    var interpolationQuality = CGInterpolationQuality.default
    var shouldAntialias = false
    
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
public class ProgressIndicatorWrapper : PlatformView {
    #if os(macOS)
    var wrapped = NSProgressIndicator()
    #else
    var wrapped = UIProgressView(progressViewStyle: .default)
    #endif
    
    #if os(macOS)
    public override func layout() {
        super.layout()
        wrapped.frame = self.bounds
        wrapped.setFrameOrigin(CGPoint(x: (self.bounds.width - wrapped.frame.width) / 2, y: (self.bounds.height - wrapped.frame.height) / 2))
    }
    #else
    public override func layoutSubviews() {
        super.layoutSubviews()
        wrapped.frame = self.bounds
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

#endif
