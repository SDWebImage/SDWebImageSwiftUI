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

// View Wrapper
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

#endif
