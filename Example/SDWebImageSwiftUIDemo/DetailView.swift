/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    let url: String
    let animated: Bool
    
    var body: some View {
        Group {
            if animated {
                AnimatedImage(url: URL(string:url), options: [.progressiveLoad])
                .resizable()
                .scaledToFit()
            } else {
                WebImage(url: URL(string:url), options: [.progressiveLoad])
                .resizable()
                .scaledToFit()
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic", animated: false)
    }
}
#endif
