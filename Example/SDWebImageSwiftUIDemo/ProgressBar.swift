/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI

/// A linear view that depicts the progress of a task over time.
public struct ProgressBar: View {
    @Binding var value: CGFloat
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                     .frame(width: geometry.size.width)
                    .opacity(0.3)
                Rectangle()
                    .frame(width: geometry.size.width * self.value)
                    .opacity(0.6)
            }
        }
        .cornerRadius(2)
    }
}
