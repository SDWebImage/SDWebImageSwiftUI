/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

/// A Image View type to load image from url. Supports static/animated image format.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WebImage : View {
    static var emptyImage = PlatformImage()
    var configurations: [(Image) -> Image] = []
    
    var placeholder: AnyView?
    var retryOnAppear: Bool = true
    var cancelOnDisappear: Bool = true
    
    @ObservedObject var imageManager: ImageManager
    
    // Animated Image support (Beta)
    var animated: Bool = false
    @State var currentFrame: PlatformImage? = nil
    @State var imagePlayer: SDAnimatedImagePlayer? = nil
    
    /// Create a web image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.imageManager = ImageManager(url: url, options: options, context: context)
    }
    
    public var body: some View {
        // load remote image when first called `body`, SwiftUI sometimes will create a new View struct without calling `onAppear` (like enter EditMode) :)
        // this can ensure we load the image, and display image synchronously when memory cache hit to avoid flashing
        // called once per struct, SDWebImage take care of the duplicated query
        if imageManager.isFirstLoad {
            imageManager.load()
        }
        return Group {
            if imageManager.image != nil {
                if animated {
                    if currentFrame != nil {
                        configurations.reduce(Image(platformImage: currentFrame!)) { (previous, configuration) in
                            configuration(previous)
                        }
                        .onAppear {
                            self.imagePlayer?.startPlaying()
                        }
                        .onDisappear {
                            self.imagePlayer?.pausePlaying()
                        }
                    } else {
                        configurations.reduce(Image(platformImage: imageManager.image!)) { (previous, configuration) in
                            configuration(previous)
                        }
                        .onReceive(imageManager.$image) { image in
                            self.setupPlayer(image: image)
                        }
                    }
                } else {
                    configurations.reduce(Image(platformImage: imageManager.image!)) { (previous, configuration) in
                        configuration(previous)
                    }
                }
            } else {
                Group {
                    if placeholder != nil {
                        placeholder
                    } else {
                        // Should not use `EmptyView`, which does not respect to the container's frame modifier
                        // Using a empty image instead for better compatible
                        configurations.reduce(Image(platformImage: WebImage.emptyImage)) { (previous, configuration) in
                            configuration(previous)
                        }
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
}

// Layout
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WebImage {
    
    /// Associate a placeholder when loading image with url
    /// - note: The differences between Placeholder and Indicator, is that placeholder does not supports animation, and return type is different
    /// - Parameter content: A view that describes the placeholder.
    public func placeholder<T>(@ViewBuilder content: () -> T) -> WebImage where T : View {
        var result = self
        result.placeholder = AnyView(content())
        return result
    }
    
    /// Associate a placeholder image when loading image with url
    /// - note: This placeholder image will apply the same size and resizable from WebImage for convenience. If you don't want this, use the ViewBuilder one above instead
    /// - Parameter image: A Image view that describes the placeholder.
    public func placeholder(_ image: Image) -> WebImage {
        return placeholder {
            configurations.reduce(image) { (previous, configuration) in
                configuration(previous)
            }
        }
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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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

// Animated Image support (Beta)
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WebImage {
    
    /// Make the image to support animated images. The animation will start when view appears, and pause when disappears.
    /// - Note: Currently we do not have advanced control like binding, reset frame index, playback rate, etc. For those use case, it's recommend to use `AnimatedImage` type instead. (support iOS/tvOS/macOS)
    /// - Warning: This API need polishing. In the future we may choose to create a new View type instead.
    ///
    /// - Parameter animated: Whether or not to enable animationn.
    public func animated(_ animated: Bool = true) -> WebImage {
        var result = self
        result.animated = animated
        if animated {
            // Update Image Manager
            result.imageManager.cancel()
            var context = result.imageManager.context ?? [:]
            context[.animatedImageClass] = SDAnimatedImage.self
            result.imageManager.context = context
            result.imageManager.load()
        } else {
            // Update Image Manager
            result.imageManager.cancel()
            var context = result.imageManager.context ?? [:]
            context[.animatedImageClass] = nil
            result.imageManager.context = context
            result.imageManager.load()
        }
        return result
    }
    
    func setupPlayer(image: PlatformImage?) {
        if imagePlayer != nil {
            return
        }
        if let animatedImage = image as? SDAnimatedImageProvider {
            if let imagePlayer = SDAnimatedImagePlayer(provider: animatedImage) {
                imagePlayer.animationFrameHandler = { (_, frame) in
                    self.currentFrame = frame
                }
                self.imagePlayer = imagePlayer
                imagePlayer.startPlaying()
            }
        }
    }
}

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
