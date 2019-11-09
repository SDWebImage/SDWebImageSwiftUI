/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage
#if canImport(SDWebImageSwiftUIObjC)
import SDWebImageSwiftUIObjC
#endif

// Convenient
#if os(watchOS)
public typealias AnimatedImageViewWrapper = SDAnimatedImageInterfaceWrapper
#endif

// Coordinator Life Cycle Binding Object
public final class AnimatedImageCoordinator: NSObject {
    
    /// Any user-provided object for actual coordinator, such as delegate method, taget-action
    public var object: Any?
    
    /// Any user-provided info stored into coordinator, such as status value used for coordinator
    public var userInfo: [AnyHashable : Any]?
}

// View
public struct AnimatedImage : PlatformViewRepresentable {
    // Options
    var url: URL?
    var webOptions: SDWebImageOptions = []
    var webContext: [SDWebImageContextOption : Any]? = nil
    
    // Completion Handler
    var successBlock: ((PlatformImage, SDImageCacheType) -> Void)?
    var failureBlock: ((Error) -> Void)?
    var progressBlock: ((Int, Int) -> Void)?
    
    // Layout
    var contentMode: ContentMode?
    var aspectRatio: CGFloat?
    var capInsets: EdgeInsets = EdgeInsets()
    var resizingMode: Image.ResizingMode?
    var renderingMode: Image.TemplateRenderingMode?
    var interpolation: Image.Interpolation?
    var antialiased: Bool = false
    
    // Configuration
    var incrementalLoad: Bool?
    var maxBufferSize: UInt?
    var customLoopCount: Int?
    var runLoopMode: RunLoop.Mode?
    var pausable: Bool?
    var purgeable: Bool?
    var playBackRate: Double?
    #if os(macOS) || os(iOS) || os(tvOS)
    // These configurations only useful for web image loading
    var indicator: SDWebImageIndicator?
    var transition: SDWebImageTransition?
    #endif
    var placeholder: PlatformImage?
    
    // Coordinator
    var viewCreateBlock: ((PlatformView, Context) -> Void)?
    var viewUpdateBlock: ((PlatformView, Context) -> Void)?
    static var viewDestroyBlock: ((PlatformView, Coordinator) -> Void)?
    
    /// Current loaded image, may be `SDAnimatedImage` type
    @State public var image: PlatformImage?
    
    /// A Binding to control the animation. You can bind external logic to control the animation status.
    /// True to start animation, false to stop animation.
    @Binding public var isAnimating: Bool
    
    /// Create an animated image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter placeholder: The placeholder image to show during loading
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.init(url: url, options: options, context: context, isAnimating: .constant(true))
    }
    
    /// Create an animated image with url, placeholder, custom options and context, including animation control binding.
    /// - Parameter url: The image url
    /// - Parameter placeholder: The placeholder image to show during loading
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    /// - Parameter isAnimating: The binding for animation control
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        self.webOptions = options
        self.webContext = context
        self.url = url
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
        _image = .init(wrappedValue: image)
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
        _image = .init(wrappedValue: image)
    }
    
    #if os(macOS)
    public typealias NSViewType = AnimatedImageViewWrapper
    #elseif os(iOS) || os(tvOS)
    public typealias UIViewType = AnimatedImageViewWrapper
    #elseif os(watchOS)
    public typealias WKInterfaceObjectType = AnimatedImageViewWrapper
    #endif
    
    public typealias Coordinator = AnimatedImageCoordinator
    
    public func makeCoordinator() -> Coordinator {
        AnimatedImageCoordinator()
    }
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: AnimatedImageViewWrapper, context: NSViewRepresentableContext<AnimatedImage>) {
        updateView(nsView, context: context)
    }
    
    public static func dismantleNSView(_ nsView: AnimatedImageViewWrapper, coordinator: Coordinator) {
        dismantleView(nsView, coordinator: coordinator)
    }
    #elseif os(iOS) || os(tvOS)
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: AnimatedImageViewWrapper, context: UIViewRepresentableContext<AnimatedImage>) {
        updateView(uiView, context: context)
    }
    
    public static func dismantleUIView(_ uiView: AnimatedImageViewWrapper, coordinator: Coordinator) {
        dismantleView(uiView, coordinator: coordinator)
    }
    #elseif os(watchOS)
    public func makeWKInterfaceObject(context: WKInterfaceObjectRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateWKInterfaceObject(_ wkInterfaceObject: AnimatedImageViewWrapper, context: WKInterfaceObjectRepresentableContext<AnimatedImage>) {
        updateView(wkInterfaceObject, context: context)
    }
    
    public static func dismantleWKInterfaceObject(_ wkInterfaceObject: AnimatedImageViewWrapper, coordinator: Coordinator) {
        dismantleView(wkInterfaceObject, coordinator: coordinator)
    }
    #endif
    
    func loadImage(_ view: AnimatedImageViewWrapper, url: URL) {
        let operationKey = NSStringFromClass(type(of: view.wrapped))
        let currentOperation = view.wrapped.sd_imageLoadOperation(forKey: operationKey)
        if currentOperation != nil {
            return
        }
        view.wrapped.sd_setImage(with: url, placeholderImage: placeholder, options: webOptions, context: webContext, progress: { (receivedSize, expectedSize, _) in
            self.progressBlock?(receivedSize, expectedSize)
        }) { (image, error, cacheType, _) in
            DispatchQueue.main.async {
                self.image = image
            }
            if let image = image {
                self.successBlock?(image, cacheType)
            } else {
                self.failureBlock?(error ?? NSError())
            }
        }
    }
    
    func makeView(context: Context) -> AnimatedImageViewWrapper {
        let view = AnimatedImageViewWrapper()
        if let viewCreateBlock = viewCreateBlock {
            viewCreateBlock(view.wrapped, context)
        }
        return view
    }
    
    func updateView(_ view: AnimatedImageViewWrapper, context: Context) {
        if let image = self.image {
            #if os(watchOS)
            view.wrapped.setImage(image)
            #else
            view.wrapped.image = image
            #endif
        } else {
            if let url = url {
                #if os(macOS) || os(iOS) || os(tvOS)
                view.wrapped.sd_imageIndicator = self.indicator
                view.wrapped.sd_imageTransition = self.transition
                #endif
                loadImage(view, url: url)
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
        #if os(watchOS)
        // when onAppear/onDisappear, SwiftUI will call this `updateView(_:context:)`
        // we use this to start/stop animation, implements `SDAnimatedImageView` like behavior
        DispatchQueue.main.async {
            view.wrapped.updateAnimation()
        }
        #endif
        #endif
        
        configureView(view, context: context)
        layoutView(view, context: context)
        if let viewUpdateBlock = viewUpdateBlock {
            viewUpdateBlock(view.wrapped, context)
        }
    }
    
    static func dismantleView(_ view: AnimatedImageViewWrapper, coordinator: Coordinator) {
        view.wrapped.sd_cancelCurrentImageLoad()
        #if os(macOS)
        view.wrapped.animates = false
        #else
        view.wrapped.stopAnimating()
        #endif
        if let viewDestroyBlock = viewDestroyBlock {
            viewDestroyBlock(view.wrapped, coordinator)
        }
    }
    
    func layoutView(_ view: AnimatedImageViewWrapper, context: Context) {
        // AspectRatio && ContentMode
        #if os(macOS)
        let contentMode: NSImageScaling
        #elseif os(iOS) || os(tvOS)
        let contentMode: UIView.ContentMode
        #elseif os(watchOS)
        let contentMode: SDImageScaleMode
        #endif
        if let _ = self.aspectRatio {
            // If `aspectRatio` is not `nil`, always scale to fill and SwiftUI will layout the container with custom aspect ratio.
            #if os(macOS)
            contentMode = .scaleAxesIndependently
            #elseif os(iOS) || os(tvOS)
            contentMode = .scaleToFill
            #elseif os(watchOS)
            contentMode = .fill
            #endif
        } else {
            // If `aspectRatio` is `nil`, the resulting view maintains this view's aspect ratio.
            switch self.contentMode {
            case .fill:
                #if os(macOS)
                // Actually, NSImageView have no `.aspectFill` unlike UIImageView, only `CALayerContentsGravity.resizeAspectFill` have the same concept
                // However, using `.scaleProportionallyUpOrDown`, SwiftUI still layout the HostingView correctly, so this is OK
                contentMode = .scaleProportionallyUpOrDown
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleAspectFill
                #elseif os(watchOS)
                contentMode = .aspectFill
                #endif
            case .fit:
                #if os(macOS)
                contentMode = .scaleProportionallyUpOrDown
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleAspectFit
                #elseif os(watchOS)
                contentMode = .aspectFit
                #endif
            case .none:
                // If `contentMode` is not set at all, using scale to fill as SwiftUI default value
                #if os(macOS)
                contentMode = .scaleAxesIndependently
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleToFill
                #elseif os(watchOS)
                contentMode = .fill
                #endif
            }
        }
        
        #if os(macOS)
        view.wrapped.imageScaling = contentMode
        #else
        view.wrapped.contentMode = contentMode
        #endif
        
        // Animated Image does not support resizing mode and rendering mode
        if let image = self.image, !image.sd_isAnimated, !image.conforms(to: SDAnimatedImageProtocol.self) {
            var image = image
            // ResizingMode
            if let resizingMode = self.resizingMode, capInsets != EdgeInsets() {
                #if os(macOS)
                let capInsets = NSEdgeInsets(top: self.capInsets.top, left: self.capInsets.leading, bottom: self.capInsets.bottom, right: self.capInsets.trailing)
                #else
                let capInsets = UIEdgeInsets(top: self.capInsets.top, left: self.capInsets.leading, bottom: self.capInsets.bottom, right: self.capInsets.trailing)
                #endif
                switch resizingMode {
                case .stretch:
                    #if os(macOS)
                    view.wrapped.image?.resizingMode = .stretch
                    view.wrapped.image?.capInsets = capInsets
                    #else
                    image = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
                    #if os(iOS) || os(tvOS)
                    view.wrapped.image = image
                    #elseif os(watchOS)
                    view.wrapped.setImage(image)
                    #endif
                    #endif
                case .tile:
                    #if os(macOS)
                    view.wrapped.image?.resizingMode = .tile
                    view.wrapped.image?.capInsets = capInsets
                    #else
                    image = image.resizableImage(withCapInsets: capInsets, resizingMode: .tile)
                    #if os(iOS) || os(tvOS)
                    view.wrapped.image = image
                    #elseif os(watchOS)
                    view.wrapped.setImage(image)
                    #endif
                    #endif
                @unknown default:
                    // Future cases, not implements
                    break
                }
            }
            
            // RenderingMode
            if let renderingMode = self.renderingMode {
                switch renderingMode {
                case .template:
                    #if os(macOS)
                    view.wrapped.image?.isTemplate = true
                    #else
                    image = image.withRenderingMode(.alwaysTemplate)
                    #if os(iOS) || os(tvOS)
                    view.wrapped.image = image
                    #elseif os(watchOS)
                    view.wrapped.setImage(image)
                    #endif
                    #endif
                case .original:
                    #if os(macOS)
                    view.wrapped.image?.isTemplate = false
                    #else
                    image = image.withRenderingMode(.alwaysOriginal)
                    #if os(iOS) || os(tvOS)
                    view.wrapped.image = image
                    #elseif os(watchOS)
                    view.wrapped.setImage(image)
                    #endif
                    #endif
                @unknown default:
                    // Future cases, not implements
                    break
                }
            }
        }
        
        #if os(macOS) || os(iOS) || os(tvOS)
        // Interpolation
        if let interpolation = self.interpolation {
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
        view.shouldAntialias = self.antialiased
        #endif
        
        view.invalidateIntrinsicContentSize()
    }
    
    func configureView(_ view: AnimatedImageViewWrapper, context: Context) {
        #if os(macOS) || os(iOS) || os(tvOS)
        // IncrementalLoad
        if let incrementalLoad = self.incrementalLoad {
            view.wrapped.shouldIncrementalLoad = incrementalLoad
        }
        
        // MaxBufferSize
        if let maxBufferSize = self.maxBufferSize {
            view.wrapped.maxBufferSize = maxBufferSize
        } else {
            // automatically
            view.wrapped.maxBufferSize = 0
        }
        
        // CustomLoopCount
        if let customLoopCount = self.customLoopCount {
            view.wrapped.shouldCustomLoopCount = true
            view.wrapped.animationRepeatCount = customLoopCount
        } else {
            // disable custom loop count
            view.wrapped.shouldCustomLoopCount = false
        }
        #elseif os(watchOS)
        if let customLoopCount = self.customLoopCount {
            view.wrapped.animationRepeatCount = customLoopCount as NSNumber
        } else {
            // disable custom loop count
            view.wrapped.animationRepeatCount = nil
        }
        #endif
        
        // RunLoop Mode
        if let runLoopMode = self.runLoopMode {
            view.wrapped.runLoopMode = runLoopMode
        } else {
            view.wrapped.runLoopMode = .common
        }
        
        // Pausable
        if let pausable = self.pausable {
            view.wrapped.resetFrameIndexWhenStopped = !pausable
        } else {
            view.wrapped.resetFrameIndexWhenStopped = false
        }
        
        // Clear Buffer
        if let purgeable = self.purgeable {
            view.wrapped.clearBufferWhenStopped = purgeable
        } else {
            view.wrapped.clearBufferWhenStopped = false
        }
        
        // Playback Rate
        if let playBackRate = self.playBackRate {
            view.wrapped.playbackRate = playBackRate
        } else {
            view.wrapped.playbackRate = 1.0
        }
    }
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
        var result = self
        result.capInsets = capInsets
        result.resizingMode = resizingMode
        return result
    }
    
    /// Configurate this view's rendering mode.
    /// - Warning: Animated Image does not implementes.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> AnimatedImage {
        var result = self
        result.renderingMode = renderingMode
        return result
    }
    
    /// Configurate this view's image interpolation quality
    /// - Parameter interpolation: The interpolation quality
    public func interpolation(_ interpolation: Image.Interpolation) -> AnimatedImage {
        var result = self
        result.interpolation = interpolation
        return result
    }
    
    /// Configurate this view's image antialiasing
    /// - Parameter isAntialiased: Whether or not to allow antialiasing
    public func antialiased(_ isAntialiased: Bool) -> AnimatedImage {
        var result = self
        result.antialiased = isAntialiased
        return result
    }
}

// Aspect Ratio
extension AnimatedImage {
    /// Constrains this view's dimensions to the specified aspect ratio.
    /// - Parameters:
    ///   - aspectRatio: The ratio of width to height to use for the resulting
    ///     view. If `aspectRatio` is `nil`, the resulting view maintains this
    ///     view's aspect ratio.
    ///   - contentMode: A flag indicating whether this view should fit or
    ///     fill the parent context.
    /// - Returns: A view that constrains this view's dimensions to
    ///   `aspectRatio`, using `contentMode` as its scaling algorithm.
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> some View {
        // The `SwifUI.View.aspectRatio(_:contentMode:)` says:
        // If `aspectRatio` is `nil`, the resulting view maintains this view's aspect ratio
        // But 1: there are no public API to declare what `this view's aspect ratio` is
        // So, if we don't override this method, SwiftUI ignore the content mode on actual ImageView
        // To workaround, we want to call the default `SwifUI.View.aspectRatio(_:contentMode:)` method
        // But 2: there are no way to call a Protocol Extention default implementation in Swift 5.1
        // So, we need a hack, that create a empty modifier, they call method on that view instead
        // Fired Radar: FB7413534
        var result = self
        result.aspectRatio = aspectRatio
        result.contentMode = contentMode
        return result.modifier(EmptyModifier()).aspectRatio(aspectRatio, contentMode: contentMode)
    }

    /// Constrains this view's dimensions to the aspect ratio of the given size.
    /// - Parameters:
    ///   - aspectRatio: A size specifying the ratio of width to height to use
    ///     for the resulting view.
    ///   - contentMode: A flag indicating whether this view should fit or
    ///     fill the parent context.
    /// - Returns: A view that constrains this view's dimensions to
    ///   `aspectRatio`, using `contentMode` as its scaling algorithm.
    public func aspectRatio(_ aspectRatio: CGSize, contentMode: ContentMode) -> some View {
        var ratio: CGFloat?
        if aspectRatio.width > 0 && aspectRatio.height > 0 {
            ratio = aspectRatio.width / aspectRatio.height
        } else {
            NSException(name: .invalidArgumentException, reason: "\(type(of: self)).\(#function) should be called with positive aspectRatio", userInfo: nil).raise()
        }
        return self.aspectRatio(ratio, contentMode: contentMode)
    }

    /// Scales this view to fit its parent.
    /// - Returns: A view that scales this view to fit its parent,
    ///   maintaining this view's aspect ratio.
    public func scaledToFit() -> some View {
        return self.aspectRatio(nil, contentMode: .fit)
    }
    
    /// Scales this view to fill its parent.
    /// - Returns: A view that scales this view to fit its parent,
    ///   maintaining this view's aspect ratio.
    public func scaledToFill() -> some View {
        return self.aspectRatio(nil, contentMode: .fill)
    }
}

// AnimatedImage Modifier
extension AnimatedImage {
    
    /// Total loop count for animated image rendering. Defaults to nil.
    /// - Note: Pass nil to disable customization, use the image itself loop count (`animatedImageLoopCount`) instead
    /// - Parameter loopCount: The animation loop count
    public func customLoopCount(_ loopCount: Int?) -> AnimatedImage {
        var result = self
        result.customLoopCount = loopCount
        return result
    }
    
    /// Provide a max buffer size by bytes. This is used to adjust frame buffer count and can be useful when the decoding cost is expensive (such as Animated WebP software decoding). Default is nil.
    ///
    /// `0` or nil means automatically adjust by calculating current memory usage.
    /// `1` means without any buffer cache, each of frames will be decoded and then be freed after rendering. (Lowest Memory and Highest CPU)
    /// `UInt.max` means cache all the buffer. (Lowest CPU and Highest Memory)
    /// - Warning: watchOS does not implementes.
    /// - Parameter bufferSize: The max buffer size
    public func maxBufferSize(_ bufferSize: UInt?) -> AnimatedImage {
        var result = self
        result.maxBufferSize = bufferSize
        return result
    }
    
    /// Whehter or not to enable incremental image load for animated image. See `SDAnimatedImageView` for detailed explanation for this.
    /// - Note: If you are confused about this description, open Chrome browser to view some large GIF images with low network speed to see the animation behavior.
    /// Default is true. Set to false to only render the static poster for incremental animated image.
    /// - Warning: watchOS does not implementes.
    /// - Parameter incrementalLoad: Whether or not to incremental load
    public func incrementalLoad(_ incrementalLoad: Bool) -> AnimatedImage {
        var result = self
        result.incrementalLoad = incrementalLoad
        return result
    }
    
    /// The runLoopMode when animation is playing on. Defaults is `.common`
    ///  You can specify a runloop mode to let it rendering.
    /// - Note: This is useful for some cases, for example, always specify NSDefaultRunLoopMode, if you want to pause the animation when user scroll (for Mac user, drag the mouse or touchpad)
    /// - Parameter runLoopMode: The runLoopMode for animation
    public func runLoopMode(_ runLoopMode: RunLoop.Mode) -> AnimatedImage {
        var result = self
        result.runLoopMode = runLoopMode
        return result
    }
    
    /// Whether or not to pause the animation (keep current frame), instead of stop the animation (frame index reset to 0). When `isAnimating` binding value changed to false. Defaults is true.
    /// - Note: For some of use case, you may want to reset the frame index to 0 when stop, but some other want to keep the current frame index.
    /// - Parameter pausable: Whether or not to pause the animation instead of stop the animation.
    public func pausable(_ pausable: Bool) -> AnimatedImage {
        var result = self
        result.pausable = pausable
        return result
    }
    
    /// Whether or not to clear frame buffer cache when stopped. Defaults is false.
    /// Note: This is useful when you want to limit the memory usage during frequently visibility changes (such as image view inside a list view, then push and pop)
    /// - Parameter purgeable: Whether or not to clear frame buffer cache when stopped.
    public func purgeable(_ purgeable: Bool) -> AnimatedImage {
        var result = self
        result.purgeable = purgeable
        return result
    }
    
    /// Control the animation playback rate. Default is 1.0.
    /// `1.0` means the normal speed.
    /// `0.0` means stopping the animation.
    /// `0.0-1.0` means the slow speed.
    /// `> 1.0` means the fast speed.
    /// `< 0.0` is not supported currently and stop animation. (may support reverse playback in the future)
    /// - Parameter playBackRate: The animation playback rate.
    public func playBackRate(_ playBackRate: Double) -> AnimatedImage {
        var result = self
        result.playBackRate = playBackRate
        return result
    }
}

// Completion Handler
extension AnimatedImage {
    
    /// Provide the action when image load fails.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the error during loading. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load fails.
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> AnimatedImage {
        var result = self
        result.failureBlock = action
        return result
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, SDImageCacheType) -> Void)? = nil) -> AnimatedImage {
        var result = self
        result.successBlock = action
        return result
    }
    
    /// Provide the action when image load progress changes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the received size, the second arg is the total size, all in bytes. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> AnimatedImage {
        var result = self
        result.progressBlock = action
        return result
    }
}

// View Coordinator Handler
extension AnimatedImage {
    
    /// Provide the action when view representable create the native view.
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the context.
    /// - Returns: A view that triggers `action` when view representable create the native view.
    public func onViewCreate(perform action: ((PlatformView, Context) -> Void)? = nil) -> AnimatedImage {
        var result = self
        result.viewCreateBlock = action
        return result
    }
    
    /// Provide the action when view representable update the native view.
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the context.
    /// - Returns: A view that triggers `action` when view representable update the native view.
    public func onViewUpdate(perform action: ((PlatformView, Context) -> Void)? = nil) -> AnimatedImage {
        var result = self
        result.viewUpdateBlock = action
        return result
    }
    
    /// Provide the action when view representable destroy the native view
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the coordinator (with userInfo).
    /// - Returns: A view that triggers `action` when view representable destroy the native view.
    public static func onViewDestroy(perform action: ((PlatformView, Coordinator) -> Void)? = nil) {
        self.viewDestroyBlock = action
    }
}

// Web Image convenience
extension AnimatedImage {
    
    /// Associate a placeholder when loading image with url
    /// - Parameter content: A view that describes the placeholder.
    public func placeholder(_ placeholder: PlatformImage?) -> AnimatedImage {
        var result = self
        result.placeholder = placeholder
        return result
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// Associate a indicator when loading image with url
    /// - Note: If you do not need indicator, specify nil. Defaults to nil
    /// - Parameter indicator: indicator, see more in `SDWebImageIndicator`
    public func indicator(_ indicator: SDWebImageIndicator?) -> AnimatedImage {
        var result = self
        result.indicator = indicator
        return result
    }
    
    /// Associate a transition when loading image with url
    /// - Note: If you specify nil, do not do transition. Defautls to nil.
    /// - Parameter transition: transition, see more in `SDWebImageTransition`
    public func transition(_ transition: SDWebImageTransition?) -> AnimatedImage {
        var result = self
        result.transition = transition
        return result
    }
    #endif
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
