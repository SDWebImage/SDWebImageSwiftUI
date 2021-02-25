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

#if os(watchOS)
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension Indicator where T == ProgressView<EmptyView, EmptyView> {
    static var activity: Indicator {
        Indicator { isAnimating, progress in
            ProgressView()
        }
    }
    
    static var progress: Indicator {
        Indicator { isAnimating, progress in
            ProgressView(value: progress.wrappedValue)
        }
    }
}
#endif

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
    "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
    "https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic",
    "https://www.sample-videos.com/img/Sample-png-image-1mb.png",
    "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
    "https://raw.githubusercontent.com/ibireme/YYImage/master/Demo/YYImageDemo/mew_baseline.jpg",
    "https://via.placeholder.com/200x200.jpg",
    "https://raw.githubusercontent.com/recurser/exif-orientation-examples/master/Landscape_5.jpg",
    "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/w3c.svg",
    "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/wikimedia.svg",
    "https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/stack_of_photos.pdf",
    "https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/smartphone_tablet.pdf"
    ]
    @State var animated: Bool = true // You can change between WebImage/AnimatedImage
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
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
        return contentView()
            .contextMenu {
                Button(action: { self.reloadCache() }) {
                    Text("Reload")
                }
                Button(action: { self.switchView() }) {
                    Text("Switch")
                }
            }
        #endif
    }
    
    func contentView() -> some View {
        List {
            ForEach(imageURLs, id: \.self) { url in
                NavigationLink(destination: DetailView(url: url, animated: self.animated)) {
                    HStack {
                        if self.animated {
                            #if os(macOS) || os(iOS) || os(tvOS)
                            AnimatedImage(url: URL(string:url), isAnimating: .constant(true))
                            .onViewUpdate { view, context in
                            #if os(macOS)
                                view.toolTip = url
                            #endif
                            }
                            .indicator(SDWebImageActivityIndicator.medium)
                            /**
                            .placeholder(UIImage(systemName: "photo"))
                            */
                            .transition(.fade)
                            .resizable()
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #else
                            WebImage(url: URL(string:url), isAnimating: self.$animated)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #endif
                        } else {
                            WebImage(url: URL(string:url), isAnimating: .constant(true))
                            .resizable()
                            /**
                             .placeholder {
                                 Image(systemName: "photo")
                             }
                             */
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
