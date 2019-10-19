/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

// Data Binding Object
final class AnimatedImageModel : ObservableObject {
    @Published var image: PlatformImage?
    @Published var url: URL?
    @Published var successBlock: ((PlatformImage, SDImageCacheType) -> Void)?
    @Published var failureBlock: ((Error) -> Void)?
    @Published var progressBlock: ((Int, Int) -> Void)?
}

// Layout Binding Object
final class AnimatedImageLayout : ObservableObject {
    @Published var contentMode: ContentMode = .fill
    @Published var aspectRatio: CGFloat?
    @Published var capInsets: EdgeInsets = EdgeInsets()
    @Published var resizingMode: Image.ResizingMode?
    @Published var renderingMode: Image.TemplateRenderingMode?
    @Published var interpolation: Image.Interpolation?
    @Published var antialiased: Bool = false
}

// Configuration Binding Object
final class AnimatedImageConfiguration: ObservableObject {
    @Published var incrementalLoad: Bool?
    @Published var maxBufferSize: UInt?
    @Published var customLoopCount: Int?
}

// View
public struct AnimatedImage : PlatformViewRepresentable {
    @ObservedObject var imageModel = AnimatedImageModel()
    @ObservedObject var imageLayout = AnimatedImageLayout()
    @ObservedObject var imageConfiguration = AnimatedImageConfiguration()
    
    var placeholder: PlatformImage?
    var webOptions: SDWebImageOptions = []
    var webContext: [SDWebImageContextOption : Any]? = nil
    
    /// A Binding to control the animation. You can bind external logic to control the animation status.
    /// True to start animation, false to stop animation.
    @Binding public var isAnimating: Bool
    
    /// Create an animated image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter placeholder: The placeholder image to show during loading
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    public init(url: URL?, placeholder: PlatformImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.init(url: url, placeholder: placeholder, options: options, context: context, isAnimating: .constant(true))
    }
    
    /// Create an animated image with url, placeholder, custom options and context, including animation control binding.
    /// - Parameter url: The image url
    /// - Parameter placeholder: The placeholder image to show during loading
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    /// - Parameter isAnimating: The binding for animation control
    public init(url: URL?, placeholder: PlatformImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        self.placeholder = placeholder
        self.webOptions = options
        self.webContext = context
        self.imageModel.url = url
    }
    
    /// Create an animated image with name and bundle.
    /// - Note: Asset Catalog is not supported.
    /// - Parameter name: The image name
    /// - Parameter bundle: The bundle contains image
    public init(name: String, bundle: Bundle? = nil) {
        self.init(name: name, bundle: bundle, isAnimating: .constant(true))
    }
    
    /// Create an animated image with name and bundle, including animation control binding.
    /// - Note: Asset Catalog is not supported.
    /// - Parameter name: The image name
    /// - Parameter bundle: The bundle contains image
    /// - Parameter isAnimating: The binding for animation control
    public init(name: String, bundle: Bundle? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        #if os(macOS) || os(watchOS)
        let image = SDAnimatedImage(named: name, in: bundle)
        #else
        let image = SDAnimatedImage(named: name, in: bundle, compatibleWith: nil)
        #endif
        self.imageModel.image = image
    }
    
    /// Create an animated image with data and scale.
    /// - Parameter data: The image data
    /// - Parameter scale: The scale factor
    public init(data: Data, scale: CGFloat = 0) {
        self.init(data: data, scale: scale, isAnimating: .constant(true))
    }
    
    /// Create an animated image with data and scale, including animation control binding.
    /// - Parameter data: The image data
    /// - Parameter scale: The scale factor
    /// - Parameter isAnimating: The binding for animation control
    public init(data: Data, scale: CGFloat = 0, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        let image = SDAnimatedImage(data: data, scale: scale)
        self.imageModel.image = image
    }
    
    #if os(macOS)
    public typealias NSViewType = AnimatedImageViewWrapper
    #elseif os(iOS) || os(tvOS)
    public typealias UIViewType = AnimatedImageViewWrapper
    #elseif os(watchOS)
    public typealias WKInterfaceObjectType = SDAnimatedImageInterface
    #endif
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: AnimatedImageViewWrapper, context: NSViewRepresentableContext<AnimatedImage>) {
        updateView(nsView, context: context)
    }
    #elseif os(iOS) || os(tvOS)
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: AnimatedImageViewWrapper, context: UIViewRepresentableContext<AnimatedImage>) {
        updateView(uiView, context: context)
    }
    #endif
    
    #if os(watchOS)
    public func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<AnimatedImage>) -> SDAnimatedImageInterface {
        SDAnimatedImageInterface()
    }
    
    public func updateWKInterfaceObject(_ view: SDAnimatedImageInterface, context: WKInterfaceObjectRepresentableContext<AnimatedImage>) {
        view.setImage(imageModel.image)
        if let url = imageModel.url {
            view.sd_setImage(with: url, completed: nil)
        }
        
        if self.isAnimating {
            view.startAnimating()
        } else {
            view.stopAnimating()
        }
        
        layoutView(view, context: context)
    }
    
    func layoutView(_ view: SDAnimatedImageInterface, context: PlatformViewRepresentableContext<AnimatedImage>) {
        // AspectRatio
        if let _ = imageLayout.aspectRatio {
            // TODO: Needs layer transform and geometry calculation
        }
        
        // ContentMode
        switch imageLayout.contentMode {
        case .fit:
            view.setContentMode(.aspectFit)
        case .fill:
            view.setContentMode(.fill)
        }
    }
    #endif
    
    #if os(iOS) || os(tvOS) || os(macOS)
    func makeView(context: PlatformViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        AnimatedImageViewWrapper()
    }
    
    func updateView(_ view: AnimatedImageViewWrapper, context: PlatformViewRepresentableContext<AnimatedImage>) {
        view.wrapped.image = imageModel.image
        if let url = imageModel.url {
            view.wrapped.sd_setImage(with: url, placeholderImage: placeholder, options: webOptions, context: webContext, progress: { (receivedSize, expectedSize, _) in
                self.imageModel.progressBlock?(receivedSize, expectedSize)
            }) { (image, error, cacheType, _) in
                if let image = image {
                    self.imageModel.successBlock?(image, cacheType)
                } else {
                    self.imageModel.failureBlock?(error ?? NSError())
                }
            }
        }
        
        #if os(macOS)
        if self.isAnimating != view.wrapped.animates {
            view.wrapped.animates = self.isAnimating
        }
        #else
        if self.isAnimating != view.wrapped.isAnimating {
            if self.isAnimating {
                view.wrapped.startAnimating()
            } else {
                view.wrapped.stopAnimating()
            }
        }
        #endif
        
        configureView(view, context: context)
        layoutView(view, context: context)
    }
    
    func layoutView(_ view: AnimatedImageViewWrapper, context: PlatformViewRepresentableContext<AnimatedImage>) {
        // AspectRatio
        if let _ = imageLayout.aspectRatio {
            // TODO: Needs layer transform and geometry calculation
        }
        
        // ContentMode
        switch imageLayout.contentMode {
        case .fit:
            #if os(macOS)
            view.wrapped.imageScaling = .scaleProportionallyUpOrDown
            #else
            view.wrapped.contentMode = .scaleAspectFit
            #endif
        case .fill:
            #if os(macOS)
            view.wrapped.imageScaling = .scaleAxesIndependently
            #else
            view.wrapped.contentMode = .scaleToFill
            #endif
        }
        
        // Animated Image does not support resizing mode and rendering mode
        if let image = view.wrapped.image, !image.sd_isAnimated, !image.conforms(to: SDAnimatedImageProtocol.self) {
            // ResizingMode
            if let resizingMode = imageLayout.resizingMode {
                #if os(macOS)
                let capInsets = NSEdgeInsets(top: imageLayout.capInsets.top, left: imageLayout.capInsets.leading, bottom: imageLayout.capInsets.bottom, right: imageLayout.capInsets.trailing)
                #else
                let capInsets = UIEdgeInsets(top: imageLayout.capInsets.top, left: imageLayout.capInsets.leading, bottom: imageLayout.capInsets.bottom, right: imageLayout.capInsets.trailing)
                #endif
                switch resizingMode {
                case .stretch:
                    #if os(macOS)
                    view.wrapped.image?.resizingMode = .stretch
                    view.wrapped.image?.capInsets = capInsets
                    #else
                    view.wrapped.image = view.wrapped.image?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
                    #endif
                case .tile:
                    #if os(macOS)
                    view.wrapped.image?.resizingMode = .tile
                    view.wrapped.image?.capInsets = capInsets
                    #else
                    view.wrapped.image = view.wrapped.image?.resizableImage(withCapInsets: capInsets, resizingMode: .tile)
                    #endif
                @unknown default:
                    // Future cases, not implements
                    break
                }
            }
            
            // RenderingMode
            if let renderingMode = imageLayout.renderingMode {
                switch renderingMode {
                case .template:
                    #if os(macOS)
                    view.wrapped.image?.isTemplate = true
                    #else
                    view.wrapped.image = view.wrapped.image?.withRenderingMode(.alwaysTemplate)
                    #endif
                case .original:
                    #if os(macOS)
                    view.wrapped.image?.isTemplate = false
                    #else
                    view.wrapped.image = view.wrapped.image?.withRenderingMode(.alwaysOriginal)
                    #endif
                @unknown default:
                    // Future cases, not implements
                    break
                }
            }
        }
        
        // Interpolation
        if let interpolation = imageLayout.interpolation {
            switch interpolation {
            case .high:
                view.interpolationQuality = .high
            case .medium:
                view.interpolationQuality = .medium
            case .low:
                view.interpolationQuality = .low
            case .none:
                view.interpolationQuality = .none
            @unknown default:
                // Future cases, not implements
                break
            }
        } else {
            view.interpolationQuality = .default
        }
        
        // Antialiased
        view.shouldAntialias = imageLayout.antialiased
        
        // Display
        #if os(macOS)
        view.needsLayout = true
        view.needsDisplay = true
        #else
        view.setNeedsLayout()
        view.setNeedsDisplay()
        #endif
    }
    
    func configureView(_ view: AnimatedImageViewWrapper, context: PlatformViewRepresentableContext<AnimatedImage>) {
        // IncrementalLoad
        if let incrementalLoad = imageConfiguration.incrementalLoad {
            view.wrapped.shouldIncrementalLoad = incrementalLoad
        }
        
        // MaxBufferSize
        if let maxBufferSize = imageConfiguration.maxBufferSize {
            view.wrapped.maxBufferSize = maxBufferSize
        } else {
            // automatically
            view.wrapped.maxBufferSize = 0
        }
        
        // CustomLoopCount
        if let customLoopCount = imageConfiguration.customLoopCount {
            view.wrapped.shouldCustomLoopCount = true
            view.wrapped.animationRepeatCount = customLoopCount
        } else {
            // disable custom loop count
            view.wrapped.shouldCustomLoopCount = false
        }
    }
    #endif
}

// Layout
extension AnimatedImage {
    
    /// Configurate this view's image with the specified cap insets and options.
    /// - Warning: Animated Image does not implementes.
    /// - Parameter capInsets: The values to use for the cap insets.
    /// - Parameter resizingMode: The resizing mode
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> AnimatedImage
    {
        imageLayout.capInsets = capInsets
        imageLayout.resizingMode = resizingMode
        return self
    }
    
    /// Configurate this view's rendering mode.
    /// - Warning: Animated Image does not implementes.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> AnimatedImage {
        imageLayout.renderingMode = renderingMode
        return self
    }
    
    /// Configurate this view's image interpolation quality
    /// - Parameter interpolation: The interpolation quality
    public func interpolation(_ interpolation: Image.Interpolation) -> AnimatedImage {
        imageLayout.interpolation = interpolation
        return self
    }
    
    /// Configurate this view's image antialiasing
    /// - Parameter isAntialiased: Whether or not to allow antialiasing
    public func antialiased(_ isAntialiased: Bool) -> AnimatedImage {
        imageLayout.antialiased = isAntialiased
        return self
    }
    /// Constrains this view's dimensions to the specified aspect ratio.
    /// - Parameters:
    ///   - aspectRatio: The ratio of width to height to use for the resulting
    ///     view. If `aspectRatio` is `nil`, the resulting view maintains this
    ///     view's aspect ratio.
    ///   - contentMode: A flag indicating whether this view should fit or
    ///     fill the parent context.
    /// - Returns: A view that constrains this view's dimensions to
    ///   `aspectRatio`, using `contentMode` as its scaling algorithm.
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> AnimatedImage {
        imageLayout.aspectRatio = aspectRatio
        imageLayout.contentMode = contentMode
        return self
    }

    /// Constrains this view's dimensions to the aspect ratio of the given size.
    /// - Parameters:
    ///   - aspectRatio: A size specifying the ratio of width to height to use
    ///     for the resulting view.
    ///   - contentMode: A flag indicating whether this view should fit or
    ///     fill the parent context.
    /// - Returns: A view that constrains this view's dimensions to
    ///   `aspectRatio`, using `contentMode` as its scaling algorithm.
    public func aspectRatio(_ aspectRatio: CGSize, contentMode: ContentMode) -> AnimatedImage {
        var ratio: CGFloat?
        if aspectRatio.width > 0 && aspectRatio.height > 0 {
            ratio = aspectRatio.width / aspectRatio.height
        }
        return self.aspectRatio(ratio, contentMode: contentMode)
    }

    /// Scales this view to fit its parent.
    /// - Returns: A view that scales this view to fit its parent,
    ///   maintaining this view's aspect ratio.
    public func scaledToFit() -> AnimatedImage {
        self.aspectRatio(nil, contentMode: .fit)
    }
    
    /// Scales this view to fill its parent.
    /// - Returns: A view that scales this view to fit its parent,
    ///   maintaining this view's aspect ratio.
    public func scaledToFill() -> AnimatedImage {
        self.aspectRatio(nil, contentMode: .fill)
    }
}

// AnimatedImage Modifier
extension AnimatedImage {
    
    /// Total loop count for animated image rendering. Defaults to nil.
    /// - Note: Pass nil to disable customization, use the image itself loop count (`animatedImageLoopCount`) instead
    /// - Parameter loopCount: The animation loop count
    public func customLoopCount(_ loopCount: Int?) -> AnimatedImage {
        imageConfiguration.customLoopCount = loopCount
        return self
    }
    
    /// Provide a max buffer size by bytes. This is used to adjust frame buffer count and can be useful when the decoding cost is expensive (such as Animated WebP software decoding). Default is nil.
    // `0` or nil means automatically adjust by calculating current memory usage.
    // `1` means without any buffer cache, each of frames will be decoded and then be freed after rendering. (Lowest Memory and Highest CPU)
    // `UInt.max` means cache all the buffer. (Lowest CPU and Highest Memory)
    /// - Parameter bufferSize: The max buffer size
    public func maxBufferSize(_ bufferSize: UInt?) -> AnimatedImage {
        imageConfiguration.maxBufferSize = bufferSize
        return self
    }
    
    /// Whehter or not to enable incremental image load for animated image. See `SDAnimatedImageView` for detailed explanation for this.
    /// - Note: If you are confused about this description, open Chrome browser to view some large GIF images with low network speed to see the animation behavior.
    /// Default is true. Set to false to only render the static poster for incremental animated image.
    /// - Parameter incrementalLoad: Whether or not to incremental load
    public func incrementalLoad(_ incrementalLoad: Bool) -> AnimatedImage {
        imageConfiguration.incrementalLoad = incrementalLoad
        return self
    }
}

// Completion Handler
extension AnimatedImage {
    
    /// Provide the action when image load fails.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the error during loading. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load fails.
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> AnimatedImage {
        imageModel.failureBlock = action
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, SDImageCacheType) -> Void)? = nil) -> AnimatedImage {
        imageModel.successBlock = action
        return self
    }
    
    /// Provide the action when image load progress changes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the received size, the second arg is the total size, all in bytes. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> AnimatedImage {
        imageModel.progressBlock = action
        return self
    }
}

#if DEBUG
struct AnimatedImage_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            AnimatedImage(url: URL(string: "http://assets.sbnation.com/assets/2512203/dogflops.gif"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
        }
    }
}
#endif
