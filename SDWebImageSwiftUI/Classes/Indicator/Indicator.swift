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
public struct Indicator {
    var builder: (Binding<Bool>, Binding<CGFloat>) -> AnyView
    
    /// Create a indicator with builder
    /// - Parameter builder: A builder to build indicator
    /// - Parameter isAnimating: A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
    /// - Parameter progress: A Binding to control the progress during loading. If no progress can be reported, the value is 0.
    /// Associate a indicator when loading image with url
    public init<T>(@ViewBuilder builder: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) where T : View {
        self.builder = { isAnimating, progress in
            AnyView(builder(isAnimating, progress))
        }
    }
}

#if os(macOS) || os(iOS) || os(iOS)
extension Indicator {
    /// Activity Indicator
    public static var activity: Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating)
        }
    }
    
    /// Progress Indicator
    public static var progress: Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress)
        }
    }
}
#endif
