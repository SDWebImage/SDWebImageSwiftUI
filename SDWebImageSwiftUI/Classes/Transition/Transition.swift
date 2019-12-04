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
    
    /// Flip from left transition
    public static var flipFromLeft: AnyTransition {
        let insertion = AnyTransition.move(edge: .leading)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from right transition
    public static var flipFromRight: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from top transition
    public static var flipFromTop: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
    
    /// Flip from bottom transition
    public static var flipFromBottom: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
        let removal = AnyTransition.identity
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
}
