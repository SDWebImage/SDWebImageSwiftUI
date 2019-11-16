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
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    
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
                .resizable()
                .indicator(.progress)
                .scaledToFit()
                #else
                WebImage(url: URL(string:url), options: [.progressiveLoad])
                .resizable()
                .indicator { isAnimating, progress in
                    ProgressBar(value: progress)
                    .foregroundColor(.blue)
                    .frame(maxHeight: 6)
                }
                .scaledToFit()
                #endif
            }
        }
        .scaleEffect(self.scale)
        .gesture(MagnificationGesture().onChanged { value in
            let delta = value / self.lastScaleValue
            self.lastScaleValue = value
            let newScale = self.scale * delta
            self.scale = min(max(newScale, 0.5), 2)
        }.onEnded { value in
            self.lastScaleValue = 1.0
        })
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic", animated: false)
    }
}
#endif
