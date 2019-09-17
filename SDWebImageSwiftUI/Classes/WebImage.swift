/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

public struct WebImage : View {
    public var url: URL?
    public var placeholder: Image?
    public var options: SDWebImageOptions
    public var context: [SDWebImageContextOption : Any]?
    
    @ObservedObject var imageManager: ImageManager
    
    public init(url: URL?, placeholder: Image? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.options = options
        self.context = context
        self.imageManager = ImageManager(url: url, options: options, context: context)
    }
    
    public var body: some View {
        if let image = imageManager.image {
            return image
                .resizable()
                .onAppear {}
                .onDisappear {}
        } else if let image = placeholder {
                return image
                    .resizable()
                    .onAppear { self.imageManager.load() }
                    .onDisappear { self.imageManager.cancel() }
        } else {
            #if os(macOS)
            let emptyImage = Image(nsImage: NSImage())
            #else
            let emptyImage = Image(uiImage: UIImage())
            #endif
            return emptyImage
                .resizable()
                .onAppear { self.imageManager.load() }
                .onDisappear { self.imageManager.cancel() }
        }
    }
}
