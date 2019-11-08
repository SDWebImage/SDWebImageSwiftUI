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
    static var emptyImage = PlatformImage()
    
    var url: URL?
    var options: SDWebImageOptions
    var context: [SDWebImageContextOption : Any]?
    
    var configurations: [(Image) -> Image] = []
    
    var placeholder: AnyView?
    var retryOnAppear: Bool = true
    var cancelOnDisappear: Bool = true
    
    @State var currentFrame: PlatformImage? = nil
    
    @ObservedObject var imageManager: ImageManager
    var imagePlayer: SDAnimatedImagePlayer?
    
    /// Create a web image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
        self.options = options
        var context = context ?? [:]
        context[.animatedImageClass] = SDAnimatedImage.self
        self.context = context
        self.imageManager = ImageManager(url: url, options: options, context: context)
        // load remote image here, SwiftUI sometimes will create a new View struct without calling `onAppear` (like enter EditMode) :)
        // this can ensure we load the image, SDWebImage take care of the duplicated query
        self.imageManager.load()
    }
    
    public var body: some View {
        Group {
            if imageManager.image != nil {
                if currentFrame != nil {
                    configurations.reduce(Image(platformImage: currentFrame!)) { (previous, configuration) in
                        configuration(previous)
                    }
                } else {
                    queryFrames()
                }
            } else {
                Group {
                    if placeholder != nil {
                        placeholder
                    } else {
                        Image(platformImage: WebImage.emptyImage)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear {
                    guard self.retryOnAppear else { return }
                    if !self.imageManager.isSuccess {
                        self.imageManager.load()
                    }
                }
                .onDisappear {
                    guard self.cancelOnDisappear else { return }
                    // When using prorgessive loading, the previous partial image will cause onDisappear. Filter this case
                    if !self.imageManager.isSuccess && !self.imageManager.isIncremental {
                        self.imageManager.cancel()
                    }
                }
            }
        }
    }
    
    func queryFrames() -> some View {
        if (imageManager.image as? SDAnimatedImageProvider) != nil {
            let imagePlayer = SDAnimatedImagePlayer(provider: (imageManager.image as! SDAnimatedImageProvider))
            var result = self
            imagePlayer?.animationFrameHandler = { (_, frame) in
                result.currentFrame = frame
            }
            imagePlayer?.startPlaying()
            result.imagePlayer = imagePlayer
        }
        return configurations.reduce(Image(platformImage: imageManager.image!)) { (previous, configuration) in
            configuration(previous)
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

// WebImage Modifier
extension WebImage {
    
    /// Associate a placeholder when loading image with url
    /// - note: The differences between Placeholder and Indicator, is that placeholder does not supports animation, and return type is different
    /// - Parameter content: A view that describes the placeholder.
    public func placeholder<T>(@ViewBuilder _ content: () -> T) -> WebImage where T : View {
        var result = self
        result.placeholder = AnyView(content())
        return result
    }
    
    /// Control the behavior to retry the failed loading when view become appears again
    /// - Parameter flag: Whether or not to retry the failed loading
    public func retryOnAppear(_ flag: Bool) -> WebImage {
        var result = self
        result.retryOnAppear = flag
        return result
    }
    
    /// Control the behavior to cancel the pending loading when view become disappear again
    /// - Parameter flag: Whether or not to cancel the pending loading
    public func cancelOnDisappear(_ flag: Bool) -> WebImage {
        var result = self
        result.cancelOnDisappear = flag
        return result
    }
}

// Indicator
extension WebImage {
    
    /// Associate a indicator when loading image with url
    /// - Parameter indicator: The indicator type, see `Indicator`
    public func indicator<T>(_ indicator: Indicator<T>) -> some View where T : View {
        return self.modifier(IndicatorViewModifier(imageManager: imageManager, indicator: indicator))
    }
    
    /// Associate a indicator when loading image with url, convenient method with block
    /// - Parameter content: A view that describes the indicator.
    public func indicator<T>(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) -> some View where T : View {
        return indicator(Indicator(content: content))
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
