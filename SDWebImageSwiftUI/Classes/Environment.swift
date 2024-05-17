/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI

public struct AnimationGroup: EnvironmentKey {
    public static var defaultValue: String? { nil }
}

extension EnvironmentValues {
    public var animationGroup: String? {
        get { self[AnimationGroup.self] }
        set { self[AnimationGroup.self] = newValue }
    }
}
