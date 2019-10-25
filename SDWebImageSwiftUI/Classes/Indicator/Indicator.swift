/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

/// A container view to hold the indicator builder
public struct Indicator : View {
    var builder: (Binding<Bool>, Binding<CGFloat>) -> AnyView
    public typealias Body = Never
    public var body: Never {
        fatalError()
    }
    public init<T>(@ViewBuilder builder: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) where T : View {
        self.builder = { isAnimating, progress in
            AnyView(builder(isAnimating, progress))
        }
    }
}
