/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImageSwiftUI

class UserSettings: ObservableObject {
    // Some environment configuration
    #if os(tvOS)
    @Published var editMode: EditMode = .inactive
    @Published var zoomed: Bool = false
    #endif
}

struct ContentView5: View {
    let url: URL = URL(string: "http://assets.sbnation.com/assets/2512203/dogflops.gif")!

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            WebImage(url: url, isAnimating: $isAnimating)
                .pausable(false)
            Button {
                isAnimating.toggle()
            } label: {
                Text(isAnimating ? "Stop" : "Start")
            }
        }
    }
}

#if !os(watchOS)
struct ContentView4: View {
    var url = URL(string: "https://github.com/SDWebImage/SDWebImageSwiftUI/assets/97430818/72d27f90-e9d8-48d7-b144-82ada828a027")!
    var body: some View {
        AnimatedImage(url: url)
            .resizable()
            .scaledToFit()
//            .aspectRatio(nil, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
    }
}
#endif

// Test Switching nil url
struct ContentView3: View {
    @State var isOn = false
    @State var animated: Bool = false // You can change between WebImage/AnimatedImage

    var url: URL? {
        if isOn {
            .init(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png")
        } else {
            nil
        }
    }

    var body: some View {
        VStack {
            Text("\(animated ? "AnimatedImage" : "WebImage")")
            Spacer()
            #if os(watchOS)
            WebImage(url: url)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            #else
            if animated {
                AnimatedImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } else {
                WebImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            #endif
            Button("Toggle \(isOn ? "nil" : "valid") URL") {
                isOn.toggle()
            }
            Spacer()
            Toggle("Switch", isOn: $animated)
        }
    }
}

// Test Switching url using @State
struct ContentView2: View {
    @State var imageURLs = [
        "https://raw.githubusercontent.com/recurser/exif-orientation-examples/master/Landscape_1.jpg",
        "https://raw.githubusercontent.com/recurser/exif-orientation-examples/master/Landscape_2.jpg",
        "http://assets.sbnation.com/assets/2512203/dogflops.gif",
        "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"
    ]
    @State var animated: Bool = false // You can change between WebImage/AnimatedImage
    @State var imageIndex : Int = 0
    var body: some View {
        Group {
            Text("\(animated ? "AnimatedImage" : "WebImage") - \((imageURLs[imageIndex] as NSString).lastPathComponent)")
            Spacer()
            #if os(watchOS)
            WebImage(url:URL(string: imageURLs[imageIndex]))
            .resizable()
            .aspectRatio(contentMode: .fit)
            #else
            if self.animated {
                AnimatedImage(url:URL(string: imageURLs[imageIndex]))
                .resizable()
                .aspectRatio(contentMode: .fit)
            } else {
                WebImage(url:URL(string: imageURLs[imageIndex]))
                .resizable()
                .aspectRatio(contentMode: .fit)
            }
            #endif
            Spacer()
            Button("Next") {
                if imageIndex + 1 >= imageURLs.count {
                    imageIndex = 0
                } else {
                    imageIndex += 1
                }
            }
            Button("Reload") {
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk(onCompletion: nil)
            }
            Toggle("Switch", isOn: $animated)
        }
    }
}

struct ContentView: View {
    @State var imageURLs = [
    "http://assets.sbnation.com/assets/2512203/dogflops.gif",
    "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif",
    "http://apng.onevcat.com/assets/elephant.png",
    "http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
    "http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
    "http://littlesvr.ca/apng/images/SteamEngine.webp",
    "http://littlesvr.ca/apng/images/world-cup-2014-42.webp",
    "https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp",
    "https://raw.githubusercontent.com/link-u/avif-sample-images/master/fox.profile0.8bpc.yuv420.avif",
    "https://raw.githubusercontent.com/link-u/avif-sample-images/master/star-12bpc-with-alpha.avifs",
    "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
    "https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic",
    "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
    "https://raw.githubusercontent.com/ibireme/YYImage/master/Demo/YYImageDemo/mew_baseline.jpg",
    "https://via.placeholder.com/200x200.jpg",
    "https://raw.githubusercontent.com/recurser/exif-orientation-examples/master/Landscape_5.jpg",
    "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/w3c.svg",
    "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wikimedia.svg",
    "https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/stack_of_photos.pdf",
    "https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/smartphone_tablet.pdf"
    ]
    @State var animated: Bool = false // You can change between WebImage/AnimatedImage
    @EnvironmentObject var settings: UserSettings
    
    // Used to avoid https://twitter.com/fatbobman/status/1572507700436807683?s=20&t=5rfj6BUza5Jii-ynQatCFA
    struct ItemView: View {
        @Binding var animated: Bool
        @State var url: String
        var body: some View {
            NavigationLink(destination: DetailView(url: url, animated: self.animated)) {
                HStack {
                    if self.animated {
                        #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
                        AnimatedImage(url: URL(string:url))
                        .onViewUpdate { view, context in
                        #if os(macOS)
                            view.toolTip = url
                        #endif
                        }
                        .indicator(.activity)
                        .transition(.fade)
                        .resizable()
                        .scaledToFit()
                        .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                        #else
                        WebImage(url: URL(string:url))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                        #endif
                    } else {
                        WebImage(url: URL(string:url))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                    }
                    Text((url as NSString).lastPathComponent)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    
    var body: some View {
        #if os(visionOS)
        return NavigationView {
            contentView()
            .navigationBarTitle(animated ? "AnimatedImage" : "WebImage")
            .navigationBarItems(leading:
                Button(action: { self.reloadCache() }) {
                    Text("Reload")
                }, trailing:
                Button(action: { self.switchView() }) {
                    Text("Switch")
                }
            )
        }
        #endif
        #if os(iOS)
        return NavigationView {
            contentView()
            .navigationBarTitle(animated ? "AnimatedImage" : "WebImage")
            .navigationBarItems(leading:
                Button(action: { self.reloadCache() }) {
                    Text("Reload")
                }, trailing:
                Button(action: { self.switchView() }) {
                    Text("Switch")
                }
            )
        }
        #endif
        #if os(tvOS)
        return NavigationView {
            contentView()
            .environment(\EnvironmentValues.editMode, self.$settings.editMode)
            .navigationBarTitle(animated ? "AnimatedImage" : "WebImage")
            .navigationBarItems(leading:
                Button(action: { self.reloadCache() }) {
                    Text("Reload")
                }, trailing:
                Button(action: { self.switchView() }) {
                    Text("Switch")
                }
            )
        }
        #endif
        #if os(macOS)
        return NavigationView {
            contentView()
            .frame(minWidth: 200)
            .listStyle(SidebarListStyle())
            .contextMenu {
                Button(action: { self.reloadCache() }) {
                    Text("Reload")
                }
                Button(action: { self.switchView() }) {
                    Text("Switch")
                }
            }
        }
        #endif
        #if os(watchOS)
        return NavigationView {
            contentView()
                .navigationTitle("WebImage")
                .toolbar {
                    Button(action: { self.reloadCache() }) {
                        Text("Reload")
                    }
                }
            
        }
        #endif
    }
    
    func contentView() -> some View {
        List {
            ForEach(imageURLs, id: \.self) { url in
                // Must use top level view instead of inlined view structure
                ItemView(animated: $animated, url: url)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    self.imageURLs.remove(at: index)
                }
            }
        }
    }
    
    func reloadCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
    }
    
    func switchView() {
        SDImageCache.shared.clearMemory()
        animated.toggle()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
