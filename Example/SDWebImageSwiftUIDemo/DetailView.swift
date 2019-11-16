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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            #if os(iOS) || os(tvOS)
            if animated {
                zoomView()
                .navigationBarItems(trailing: Button(isAnimating ? "Stop" : "Start") {
                    self.isAnimating.toggle()
                })
            } else {
                zoomView()
            }
            #endif
            #if os(macOS) || os(watchOS)
            if animated {
                zoomView()
                .contextMenu {
                    Button(isAnimating ? "Stop" : "Start") {
                        self.isAnimating.toggle()
                    }
                }
            } else {
                zoomView()
            }
            #endif
        }
    }
    
    func zoomView() -> some View {
        #if os(macOS) || os(iOS) || os(tvOS)
        return contentView()
            .scaleEffect(self.scale)
                .gesture(MagnificationGesture(minimumScaleDelta: 0.1).onChanged { value in
                let delta = value / self.lastScaleValue
                self.lastScaleValue = value
                let newScale = self.scale * delta
                self.scale = min(max(newScale, 0.5), 2)
            }.onEnded { value in
                self.lastScaleValue = 1.0
            })
        #else
        return contentView()
            // SwiftUI's bug workaround (watchOS 6.1)
            // If use `.focusable(true)` here, after pop the Detail view, the Content view's List does not get focus again
            // After some debug, I found that the pipeline to change focus becomes:
            // Detail Pop (resign focus) -> Content Appear (List view become focus) -> Detail Disappear (become focus again) -> End
            // Even you use `onDisappear`, it's too late because `.focusable` is called firstly
            // Sadly, Content view's List focus is managed by SwiftUI (a UICollectionView actually), call `focusable` on Content view does nothing as well
            // So, here we must use environment or binding, to not become focus during pop :)
            .focusable(self.presentationMode.wrappedValue.isPresented)
            .scaleEffect(self.scale)
            .digitalCrownRotation($scale, from: 0.5, through: 2, by: 0.1, sensitivity: .low, isHapticFeedbackEnabled: false)
        #endif
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
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(url: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic", animated: false)
    }
}
#endif
