/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    var url: URL?
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic"))
                .scaledToFit()
                .frame(width: CGFloat(300), height: CGFloat(300), alignment: .center)
            AnimatedImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"), options: [.progressiveLoad])
                .scaledToFill()
                .frame(width: CGFloat(400), height: CGFloat(300), alignment: .center)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
