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
    @State var isAnimating: Bool = true
    
    var body: some View {
        VStack {
            #if os(iOS) || os(tvOS)
            if animated {
                contentView()
                .navigationBarItems(trailing: Button(isAnimating ? "Stop" : "Start") {
                    self.isAnimating.toggle()
                })
            } else {
                contentView()
            }
            #endif
            #if os(macOS) || os(watchOS)
            if animated {
                contentView()
                .contextMenu {
                    Button(isAnimating ? "Stop" : "Start") {
                        self.isAnimating.toggle()
                    }
                }
            } else {
                contentView()
            }
            #endif
        }
    }
    
    func contentView() -> some View {
        HStack {
            if animated {
                #if os(macOS) || os(iOS) || os(tvOS)
                AnimatedImage(url: URL(string:url), options: [.progressiveLoad], isAnimating: $isAnimating)
                .indicator(SDWebImageProgressIndicator.default)
                .resizable()
                .scaledToFit()
                #else
                AnimatedImage(url: URL(string:url), options: [.progressiveLoad], isAnimating: $isAnimating)
                .resizable()
                .scaledToFit()
                #endif
            } else {
                #if os(macOS) || os(iOS) || os(tvOS)
                WebImage(url: URL(string:url), options: [.progressiveLoad])
                .indicator(.progress)
                .resizable()
                .scaledToFit()
                #else
                WebImage(url: URL(string:url), options: [.progressiveLoad])
                .indicator { isAnimating, progress in
                    ProgressBar(value: progress)
                    .foregroundColor(.blue)
                    .frame(maxHeight: 6)
                }
                .resizable()
                .scaledToFit()
                #endif
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
