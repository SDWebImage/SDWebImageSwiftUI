/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import SwiftUI
import SDWebImageSwiftUI

// Placeholder when image load failed (with `.delayPlaceholder`)
#if !os(watchOS)
extension PlatformImage {
    static var wifiExclamationmark: PlatformImage {
        #if os(macOS)
        return PlatformImage(named: "wifi.exclamationmark")!
        #else
        return PlatformImage(systemName: "wifi.exclamationmark")!.withTintColor(.label, renderingMode: .alwaysOriginal)
        #endif
    }
}
#endif

extension Image {
    static var wifiExclamationmark: Image {
        #if os(macOS)
        return Image("wifi.exclamationmark")
        .resizable()
        #else
        return Image(systemName: "wifi.exclamationmark")
        .resizable()
        #endif
    }
}

struct DetailView: View {
    let url: String
    @State var animated: Bool = true // You can change between WebImage/AnimatedImage
    @State var isAnimating: Bool = true
    @State var lastScale: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        VStack {
            #if os(iOS) || os(tvOS) || os(visionOS)
            zoomView()
            .navigationBarItems(trailing: Button(isAnimating ? "Stop" : "Start") {
                self.isAnimating.toggle()
            })
            #endif
            #if os(macOS) || os(watchOS)
            zoomView()
            .onTapGesture {
                self.isAnimating.toggle()
            }
            #endif
        }
    }
    
    func zoomView() -> some View {
        #if os(macOS) || os(iOS) || os(visionOS)
        return contentView()
            .scaleEffect(self.scale)
            .gesture(MagnificationGesture(minimumScaleDelta: 0.1).onChanged { value in
                let delta = value / self.lastScale
                self.lastScale = value
                let newScale = self.scale * delta
                self.scale = min(max(newScale, 0.5), 2)
            }.onEnded { value in
                self.lastScale = 1.0
            })
        #endif
        #if os(tvOS)
        return contentView()
            .scaleEffect(self.scale)
            .onReceive(self.settings.$zoomed) { zoomed in
                withAnimation {
                    self.scale = zoomed ? 2 : 1
                }
            }
        #endif
        #if os(watchOS)
        return contentView()
            .scaleEffect(self.scale)
            .focusable(true)
            .digitalCrownRotation($scale, from: 0.5, through: 2, by: 0.1, sensitivity: .low, isHapticFeedbackEnabled: false)
        #endif
    }
    
    func contentView() -> some View {
        HStack {
            if animated {
                #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
                AnimatedImage(url: URL(string:url), options: [.progressiveLoad, .delayPlaceholder], isAnimating: $isAnimating, placeholderImage: .wifiExclamationmark)
                .indicator(.progress)
                .resizable()
                .scaledToFit()
                #else
                WebImage(url: URL(string:url), options: [.progressiveLoad, .delayPlaceholder], isAnimating: $isAnimating) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    Image.wifiExclamationmark
                        .resizable()
                        .scaledToFit()
                }
                .indicator(.progress)
                #endif
            } else {
                WebImage(url: URL(string:url), options: [.progressiveLoad, .delayPlaceholder], isAnimating: $isAnimating) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    Image.wifiExclamationmark
                        .resizable()
                        .scaledToFit()
                }
                .indicator(.progress(style: .circular))
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
