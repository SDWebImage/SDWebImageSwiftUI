/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

extension String : Identifiable {
    public typealias ID = Int
    public var id: Int {
        self.hashValue
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
    "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
    "https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic",
    "https://www.sample-videos.com/img/Sample-png-image-1mb.png",
    "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
    "https://raw.githubusercontent.com/ibireme/YYImage/master/Demo/YYImageDemo/mew_baseline.jpg",
    "http://via.placeholder.com/200x200.jpg"]
    @State var animated: Bool = false // You can change between WebImage/AnimatedImage
    
    var body: some View {
        #if os(iOS) || os(tvOS)
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
            ForEach(imageURLs) { url in
                NavigationLink(destination: DetailView(url: url, animated: self.animated)) {
                    HStack {
                        if self.animated {
                            #if os(macOS) || os(iOS) || os(tvOS)
                            AnimatedImage(url: URL(string:url))
                            /**
                             .onViewUpdate { view, context in
                                 view.toolTip = "Mouseover Tip"
                             }
                             */
                            .indicator(SDWebImageActivityIndicator.medium)
                            /**
                            .placeholder(UIImage(systemName: "photo"))
                            */
                            .transition(.fade)
                            .resizable()
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #else
                            AnimatedImage(url: URL(string:url))
                            .resizable()
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #endif
                        } else {
                            #if os(macOS) || os(iOS) || os(tvOS)
                            WebImage(url: URL(string:url))
                            .resizable()
                            /**
                             .placeholder {
                                 Image(systemName: "photo")
                             }
                             */
                            .indicator(.activity)
                            .animation(.easeInOut(duration: 0.5))
                            .transition(.fade)
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #else
                            WebImage(url: URL(string:url))
                            .resizable()
                            .indicator { _, _ in
                                ActivityBar()
                                .foregroundColor(Color.white)
                                .frame(width: 50, height: 50)
                            }
                            .animation(.easeInOut(duration: 0.5))
                            .transition(.fade)
                            .scaledToFit()
                            .frame(width: CGFloat(100), height: CGFloat(100), alignment: .center)
                            #endif
                        }
                        Text((url as NSString).lastPathComponent)
                    }
                }
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
