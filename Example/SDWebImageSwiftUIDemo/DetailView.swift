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
    @State var progress: CGFloat = 1
    
    var body: some View {
        VStack {
            HStack {
                ProgressBar(value: $progress)
                .foregroundColor(.blue)
                .frame(maxHeight: 6)
            }
            Spacer()
            HStack {
                if animated {
                    AnimatedImage(url: URL(string:url), options: [.progressiveLoad])
                    .onProgress(perform: { (receivedSize, expectedSize) in
                        // SwiftUI engine itself ensure the main queue dispatch
                        if (expectedSize >= 0) {
                            self.progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                        } else {
                            self.progress = 1
                        }
                    })
                    .resizable()
                    .scaledToFit()
                } else {
                    WebImage(url: URL(string:url), options: [.progressiveLoad])
                    .onProgress(perform: { (receivedSize, expectedSize) in
                        if (expectedSize >= 0) {
                            self.progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                        } else {
                            self.progress = 1
                        }
                    })
                    .resizable()
                    .scaledToFit()
                }
            }
            Spacer()
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
