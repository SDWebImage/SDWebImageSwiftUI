/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnyTransition {
    
    /// Fade-in transition
    public static var fade: AnyTransition {
        let insertion = AnyTransition.opacity
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Fade-in transition with duration
    /// - Parameter duration: transition duration, use ease-in-out
    /// - Returns: A transition with duration
    public static func fade(duration: Double) -> AnyTransition {
        let insertion = AnyTransition.opacity.animation(.easeInOut(duration: duration))
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from left transition
    public static var flipFromLeft: AnyTransition {
        let insertion = AnyTransition.move(edge: .leading)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from left transition with duration
    /// - Parameter duration: transition duration, use ease-in-out
    /// - Returns: A transition with duration
    public static func flipFromLeft(duration: Double) -> AnyTransition {
        let insertion = AnyTransition.move(edge: .leading).animation(.easeInOut(duration: duration))
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from right transition
    public static var flipFromRight: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from right transition with duration
    /// - Parameter duration: transition duration, use ease-in-out
    /// - Returns: A transition with duration
    public static func flipFromRight(duration: Double) -> AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing).animation(.easeInOut(duration: duration))
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from top transition
    public static var flipFromTop: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from top transition with duration
    /// - Parameter duration: transition duration, use ease-in-out
    /// - Returns: A transition with duration
    public static func flipFromTop(duration: Double) -> AnyTransition {
        let insertion = AnyTransition.move(edge: .top).animation(.easeInOut(duration: duration))
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from bottom transition
    public static var flipFromBottom: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from bottom transition with duration
    /// - Parameter duration: transition duration, use ease-in-out
    /// - Returns: A transition with duration
    public static func flipFromBottom(duration: Double) -> AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom).animation(.easeInOut(duration: duration))
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
}
