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
    var url: URL?
    var placeholder: Image?
    var options: SDWebImageOptions
    var context: [SDWebImageContextOption : Any]?
    
    var configurations: [(Image) -> Image] = []
    var indicator: Indicator?
    
    @ObservedObject var imageManager: ImageManager
    @State var progress: CGFloat = 0
    @State var isLoading: Bool = false
    var isFinished: Bool {
        !isLoading && (imageManager.image != nil)
    }
    
    /// Create a web image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter placeholder: The placeholder image to show during loading
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
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
        } else {
            if let placeholder = placeholder {
                image = placeholder
            } else {
                image = Image(platformImage: PlatformImage())
            }
            // load remote image here, SwiftUI sometimes will create a new View struct without calling `onAppear` (like enter EditMode) :)
            // this can ensure we load the image, SDWebImage take care of the duplicated query
            self.imageManager.load()
        }
        let view = configurations.reduce(image) { (previous, configuration) in
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
        // Convert Combine.Publisher to Binding
        .onReceive(imageManager.$isLoading) { isLoading in
            // only Apple Watch complain that "Modifying state during view update, this will cause undefined behavior."
            // Use dispatch to workaround, Thanks Apple :)
            #if os(watchOS)
            DispatchQueue.main.async {
                self.isLoading = isLoading
            }
            #else
            self.isLoading = isLoading
            #endif
        }
        .onReceive(imageManager.$progress) { progress in
            #if os(watchOS)
            DispatchQueue.main.async {
                self.progress = progress
            }
            #else
            self.progress = progress
            #endif
        }
        if let indicator = indicator {
            if isFinished {
                return AnyView(view)
            } else {
                return AnyView(
                    ZStack {
                        view
                        indicator.builder($isLoading, $progress)
                    }
                )
            }
        } else {
            return AnyView(view)
        }
    }
}

// Layout
extension WebImage {
    func configure(_ block: @escaping (Image) -> Image) -> WebImage {
        var result = self
        result.configurations.append(block)
        return result
    }
    
    /// Configurate this view's image with the specified cap insets and options.
    /// - Parameter capInsets: The values to use for the cap insets.
    /// - Parameter resizingMode: The resizing mode
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> WebImage
    {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }
    
    /// Configurate this view's rendering mode.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> WebImage {
        configure { $0.renderingMode(renderingMode) }
    }
    
    /// Configurate this view's image interpolation quality
    /// - Parameter interpolation: The interpolation quality
    public func interpolation(_ interpolation: Image.Interpolation) -> WebImage {
        configure { $0.interpolation(interpolation) }
    }
    
    /// Configurate this view's image antialiasing
    /// - Parameter isAntialiased: Whether or not to allow antialiasing
    public func antialiased(_ isAntialiased: Bool) -> WebImage {
        configure { $0.antialiased(isAntialiased) }
    }
}

// Completion Handler
extension WebImage {
    
    /// Provide the action when image load fails.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the error during loading. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load fails.
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> WebImage {
        self.imageManager.failureBlock = action
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, SDImageCacheType) -> Void)? = nil) -> WebImage {
        self.imageManager.successBlock = action
        return self
    }
    
    /// Provide the action when image load progress changes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the received size, the second arg is the total size, all in bytes. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> WebImage {
        self.imageManager.progressBlock = action
        return self
    }
}

// Indicator
extension WebImage {
    
    /// Associate a indicator when loading image with url
    /// - Parameter indicator: The indicator type, see `Indicator`
    public func indicator(_ indicator: Indicator?) -> WebImage {
        var result = self
        result.indicator = indicator
        return result
    }
    
    /// Associate a indicator when loading image with url, convenient method with block
    /// - Parameter indicator: The indicator type, see `Indicator`
    public func indicator<T>(@ViewBuilder builder: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) -> WebImage where T : View {
        var result = self
        result.indicator = Indicator(builder: builder)
        return result
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
