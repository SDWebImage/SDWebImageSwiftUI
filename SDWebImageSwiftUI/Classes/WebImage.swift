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
    
    var configurations: [(Image) -> Image] = []
    
    @ObservedObject var imageManager: ImageManager
    
    public init(url: URL?, placeholder: Image? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.options = options
        self.context = context
        self.imageManager = ImageManager(url: url, options: options, context: context)
    }
    
    public var body: some View {
        let image: Image
        if let platformImage = imageManager.image {
            image = Image(platformImage: platformImage)
        } else if let placeholder = placeholder {
            image = placeholder
        } else {
            #if os(macOS)
            let emptyImage = Image(nsImage: NSImage())
            #else
            let emptyImage = Image(uiImage: UIImage())
            #endif
            image = emptyImage
        }
        return configurations.reduce(image) { (previous, configuration) in
            configuration(previous)
        }
        .onAppear {
            if self.imageManager.image == nil {
                self.imageManager.load()
            }
        }
        .onDisappear {
            self.imageManager.cancel()
        }
    }
}

extension WebImage {
    func configure(_ block: @escaping (Image) -> Image) -> WebImage {
        var result = self
        result.configurations.append(block)
        return result
    }

    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> WebImage
    {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> WebImage {
        configure { $0.renderingMode(renderingMode) }
    }

    public func interpolation(_ interpolation: Image.Interpolation) -> WebImage {
        configure { $0.interpolation(interpolation) }
    }

    public func antialiased(_ isAntialiased: Bool) -> WebImage {
        configure { $0.antialiased(isAntialiased) }
    }
}

extension WebImage {
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> WebImage {
        self.imageManager.failureBlock = action
        return self
    }
    
    public func onSuccess(perform action: ((PlatformImage, SDImageCacheType) -> Void)? = nil) -> WebImage {
        self.imageManager.successBlock = action
        return self
    }
    
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> WebImage {
        self.imageManager.progressBlock = action
        return self
    }
}

#if DEBUG
struct WebImage_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            WebImage(url: URL(string: "https://raw.githubusercontent.com/SDWebImage/SDWebImage/master/SDWebImage_logo.png"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
        }
    }
}
#endif
