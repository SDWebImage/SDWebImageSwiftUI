/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

#if os(iOS) || os(tvOS) || os(macOS)

/// A coordinator object used for `AnimatedImage`native view  bridge for UIKit/AppKit.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public final class AnimatedImageCoordinator: NSObject {
    
    /// Any user-provided object for actual coordinator, such as delegate method, taget-action
    public var object: Any?
    
    /// Any user-provided info stored into coordinator, such as status value used for coordinator
    public var userInfo: [AnyHashable : Any]?
}

/// Data Binding Object, only properties in this object can support changes from user with @State and refresh
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnimatedImageModel : ObservableObject {
    /// URL image
    @Published var url: URL?
    @Published var webOptions: SDWebImageOptions = []
    @Published var webContext: [SDWebImageContextOption : Any]? = nil
    /// Name image
    @Published var name: String?
    @Published var bundle: Bundle?
    /// Data image
    @Published var data: Data?
    @Published var scale: CGFloat = 1
}

/// Loading Binding Object, only properties in this object can support changes from user with @State and refresh
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnimatedLoadingModel : ObservableObject, IndicatorReportable {
    @Published var image: PlatformImage? // loaded image, note when progressive loading, this will published multiple times with different partial image
    @Published var isLoading: Bool = false // whether network is loading or cache is querying, should only be used for indicator binding
    @Published var progress: Double = 0 // network progress, should only be used for indicator binding
}

/// Completion Handler Binding Object, supports dynamic @State changes
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnimatedImageHandler: ObservableObject {
    // Completion Handler
    @Published var successBlock: ((PlatformImage, Data?, SDImageCacheType) -> Void)?
    @Published var failureBlock: ((Error) -> Void)?
    @Published var progressBlock: ((Int, Int) -> Void)?
    // Coordinator Handler
    @Published var viewCreateBlock: ((PlatformView, AnimatedImage.Context) -> Void)?
    @Published var viewUpdateBlock: ((PlatformView, AnimatedImage.Context) -> Void)?
}

/// Layout Binding Object, supports dynamic @State changes
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnimatedImageLayout : ObservableObject {
    var contentMode: ContentMode?
    var aspectRatio: CGFloat?
    var capInsets: EdgeInsets = EdgeInsets()
    var resizingMode: Image.ResizingMode?
    var renderingMode: Image.TemplateRenderingMode?
    var interpolation: Image.Interpolation?
    var antialiased: Bool = false
}

/// Configuration Binding Object, supports dynamic @State changes
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnimatedImageConfiguration: ObservableObject {
    var incrementalLoad: Bool?
    var maxBufferSize: UInt?
    var customLoopCount: UInt?
    var runLoopMode: RunLoop.Mode?
    var pausable: Bool?
    var purgeable: Bool?
    var playbackRate: Double?
    // These configurations only useful for web image loading
    var indicator: SDWebImageIndicator?
    var transition: SDWebImageTransition?
    var placeholder: PlatformImage?
    var placeholderView: PlatformView? {
        didSet {
            oldValue?.removeFromSuperview()
        }
    }
}

/// A Image View type to load image from url, data or bundle. Supports animated and static image format.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct AnimatedImage : PlatformViewRepresentable {
    @ObservedObject var imageModel = AnimatedImageModel()
    @ObservedObject var imageLoading = AnimatedLoadingModel()
    @ObservedObject var imageHandler = AnimatedImageHandler()
    @ObservedObject var imageLayout = AnimatedImageLayout()
    @ObservedObject var imageConfiguration = AnimatedImageConfiguration()
    
    static var viewDestroyBlock: ((PlatformView, Coordinator) -> Void)?
    
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
        self.imageModel.url = url
        self.imageModel.webOptions = options
        self.imageModel.webContext = context
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
        self.imageModel.name = name
        self.imageModel.bundle = bundle
    }
    
    /// Create an animated image with data and scale.
    /// - Parameter data: The image data
    /// - Parameter scale: The scale factor
    public init(data: Data, scale: CGFloat = 1) {
        self.init(data: data, scale: scale, isAnimating: .constant(true))
    }
    
    /// Create an animated image with data and scale, including animation control binding.
    /// - Parameter data: The image data
    /// - Parameter scale: The scale factor
    /// - Parameter isAnimating: The binding for animation control
    public init(data: Data, scale: CGFloat = 1, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        self.imageModel.data = data
        self.imageModel.scale = scale
    }
    
    #if os(macOS)
    public typealias NSViewType = AnimatedImageViewWrapper
    #elseif os(iOS) || os(tvOS)
    public typealias UIViewType = AnimatedImageViewWrapper
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
    #endif
    
    func loadImage(_ view: AnimatedImageViewWrapper, context: Context) {
        let operationKey = NSStringFromClass(type(of: view.wrapped))
        let currentOperation = view.wrapped.sd_imageLoadOperation(forKey: operationKey)
        if currentOperation != nil {
            return
        }
        self.imageLoading.isLoading = true
        let options = imageModel.webOptions
        if options.contains(.delayPlaceholder) {
            self.imageConfiguration.placeholderView?.isHidden = true
        } else {
            self.imageConfiguration.placeholderView?.isHidden = false
        }
        var context = imageModel.webContext ?? [:]
        context[.animatedImageClass] = SDAnimatedImage.self
        view.wrapped.sd_internalSetImage(with: imageModel.url, placeholderImage: imageConfiguration.placeholder, options: options, context: context, setImageBlock: nil, progress: { (receivedSize, expectedSize, _) in
            let progress: Double
            if (expectedSize > 0) {
                progress = Double(receivedSize) / Double(expectedSize)
            } else {
                progress = 0
            }
            DispatchQueue.main.async {
                self.imageLoading.progress = progress
            }
            self.imageHandler.progressBlock?(receivedSize, expectedSize)
        }) { (image, data, error, cacheType, finished, _) in
            // This is a hack because of Xcode 11.3 bug, the @Published does not trigger another `updateUIView` call
            // Here I have to use UIKit/AppKit API to triger the same effect (the window change implicitly cause re-render)
            if let hostingView = AnimatedImage.findHostingView(from: view) {
                if let _ = hostingView.window {
                    #if os(macOS)
                    hostingView.viewDidMoveToWindow()
                    #else
                    hostingView.didMoveToWindow()
                    #endif
                }
            }
            self.imageLoading.image = image
            self.imageLoading.isLoading = false
            self.imageLoading.progress = 1
            if let image = image {
                self.imageConfiguration.placeholderView?.isHidden = true
                self.imageHandler.successBlock?(image, data, cacheType)
            } else {
                self.imageConfiguration.placeholderView?.isHidden = false
                self.imageHandler.failureBlock?(error ?? NSError())
            }
        }
    }
    
    func makeView(context: Context) -> AnimatedImageViewWrapper {
        let view = AnimatedImageViewWrapper()
        if let viewCreateBlock = imageHandler.viewCreateBlock {
            viewCreateBlock(view.wrapped, context)
        }
        return view
    }
    
    func updateView(_ view: AnimatedImageViewWrapper, context: Context) {
        // Refresh image, imageModel is the Source of Truth, switch the type
        // Although we have Source of Truth, we can check the previous value, to avoid re-generate SDAnimatedImage, which is performance-cost.
        if let name = imageModel.name, name != view.wrapped.sd_imageName {
            #if os(macOS)
            let image = SDAnimatedImage(named: name, in: imageModel.bundle)
            #else
            let image = SDAnimatedImage(named: name, in: imageModel.bundle, compatibleWith: nil)
            #endif
            view.wrapped.sd_imageName = name
            view.wrapped.image = image
        } else if let data = imageModel.data, data != view.wrapped.sd_imageData {
            let image = SDAnimatedImage(data: data, scale: imageModel.scale)
            view.wrapped.sd_imageData = data
            view.wrapped.image = image
        } else if let url = imageModel.url, url != view.wrapped.sd_imageURL {
            view.wrapped.sd_imageIndicator = imageConfiguration.indicator
            view.wrapped.sd_imageTransition = imageConfiguration.transition
            if let placeholderView = imageConfiguration.placeholderView {
                placeholderView.removeFromSuperview()
                placeholderView.isHidden = true
                // Placeholder View should below the Indicator View
                if let indicatorView = imageConfiguration.indicator?.indicatorView {
                    #if os(macOS)
                    view.wrapped.addSubview(placeholderView, positioned: .below, relativeTo: indicatorView)
                    #else
                    view.wrapped.insertSubview(placeholderView, belowSubview: indicatorView)
                    #endif
                } else {
                    view.wrapped.addSubview(placeholderView)
                }
                placeholderView.bindFrameToSuperviewBounds()
            }
            loadImage(view, context: context)
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
        if let viewUpdateBlock = imageHandler.viewUpdateBlock {
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
        #endif
        if let _ = imageLayout.aspectRatio {
            // If `aspectRatio` is not `nil`, always scale to fill and SwiftUI will layout the container with custom aspect ratio.
            #if os(macOS)
            contentMode = .scaleAxesIndependently
            #elseif os(iOS) || os(tvOS)
            contentMode = .scaleToFill
            #endif
        } else {
            // If `aspectRatio` is `nil`, the resulting view maintains this view's aspect ratio.
            switch imageLayout.contentMode {
            case .fill:
                #if os(macOS)
                // Actually, NSImageView have no `.aspectFill` unlike UIImageView, only `CALayerContentsGravity.resizeAspectFill` have the same concept
                // However, using `.scaleProportionallyUpOrDown`, SwiftUI still layout the HostingView correctly, so this is OK
                contentMode = .scaleProportionallyUpOrDown
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleAspectFill
                #endif
            case .fit:
                #if os(macOS)
                contentMode = .scaleProportionallyUpOrDown
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleAspectFit
                #endif
            case .none:
                // If `contentMode` is not set at all, using scale to fill as SwiftUI default value
                #if os(macOS)
                contentMode = .scaleAxesIndependently
                #elseif os(iOS) || os(tvOS)
                contentMode = .scaleToFill
                #endif
            }
        }
        
        #if os(macOS)
        view.wrapped.imageScaling = contentMode
        #else
        view.wrapped.contentMode = contentMode
        #endif
        
        // Resizable
        if let _ = imageLayout.resizingMode {
            view.resizable = true
        }
        
        // Animated Image does not support resizing mode and rendering mode
        if let image = view.wrapped.image, !image.conforms(to: SDAnimatedImageProtocol.self) {
            var image = image
            // ResizingMode
            if let resizingMode = imageLayout.resizingMode, imageLayout.capInsets != EdgeInsets() {
                #if os(macOS)
                let capInsets = NSEdgeInsets(top: imageLayout.capInsets.top, left: imageLayout.capInsets.leading, bottom: imageLayout.capInsets.bottom, right: imageLayout.capInsets.trailing)
                #else
                let capInsets = UIEdgeInsets(top: imageLayout.capInsets.top, left: imageLayout.capInsets.leading, bottom: imageLayout.capInsets.bottom, right: imageLayout.capInsets.trailing)
                #endif
                switch resizingMode {
                case .stretch:
                    #if os(macOS)
                    image.resizingMode = .stretch
                    image.capInsets = capInsets
                    #else
                    image = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
                    #endif
                    view.wrapped.image = image
                case .tile:
                    #if os(macOS)
                    image.resizingMode = .tile
                    image.capInsets = capInsets
                    #else
                    image = image.resizableImage(withCapInsets: capInsets, resizingMode: .tile)
                    #endif
                    view.wrapped.image = image
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
                    image.isTemplate = true
                    #else
                    image = image.withRenderingMode(.alwaysTemplate)
                    #endif
                    view.wrapped.image = image
                case .original:
                    #if os(macOS)
                    image.isTemplate = false
                    #else
                    image = image.withRenderingMode(.alwaysOriginal)
                    #endif
                    view.wrapped.image = image
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
        
        view.invalidateIntrinsicContentSize()
    }
    
    func configureView(_ view: AnimatedImageViewWrapper, context: Context) {
        // IncrementalLoad
        if let incrementalLoad = imageConfiguration.incrementalLoad {
            view.wrapped.shouldIncrementalLoad = incrementalLoad
        } else {
            view.wrapped.shouldIncrementalLoad = true
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
            view.wrapped.animationRepeatCount = Int(customLoopCount)
        } else {
            // disable custom loop count
            view.wrapped.shouldCustomLoopCount = false
        }
        
        // RunLoop Mode
        if let runLoopMode = imageConfiguration.runLoopMode {
            view.wrapped.runLoopMode = runLoopMode
        } else {
            view.wrapped.runLoopMode = .common
        }
        
        // Pausable
        if let pausable = imageConfiguration.pausable {
            view.wrapped.resetFrameIndexWhenStopped = !pausable
        } else {
            view.wrapped.resetFrameIndexWhenStopped = false
        }
        
        // Clear Buffer
        if let purgeable = imageConfiguration.purgeable {
            view.wrapped.clearBufferWhenStopped = purgeable
        } else {
            view.wrapped.clearBufferWhenStopped = false
        }
        
        // Playback Rate
        if let playbackRate = imageConfiguration.playbackRate {
            view.wrapped.playbackRate = playbackRate
        } else {
            view.wrapped.playbackRate = 1.0
        }
    }
    
    private static func findHostingView(from entry: PlatformView) -> PlatformView? {
        var superview = entry.superview
        while let s = superview {
            if NSStringFromClass(type(of: s)).contains("HostingView") {
                return s
            }
            superview = s.superview
        }
        return nil
    }
}

// Layout
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Configurate this view's image with the specified cap insets and options.
    /// - Warning: Animated Image does not implementes.
    /// - Parameter capInsets: The values to use for the cap insets.
    /// - Parameter resizingMode: The resizing mode
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> AnimatedImage
    {
        self.imageLayout.capInsets = capInsets
        self.imageLayout.resizingMode = resizingMode
        return self
    }
    
    /// Configurate this view's rendering mode.
    /// - Warning: Animated Image does not implementes.
    /// - Parameter renderingMode: The resizing mode
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> AnimatedImage {
        self.imageLayout.renderingMode = renderingMode
        return self
    }
    
    /// Configurate this view's image interpolation quality
    /// - Parameter interpolation: The interpolation quality
    public func interpolation(_ interpolation: Image.Interpolation) -> AnimatedImage {
        self.imageLayout.interpolation = interpolation
        return self
    }
    
    /// Configurate this view's image antialiasing
    /// - Parameter isAntialiased: Whether or not to allow antialiasing
    public func antialiased(_ isAntialiased: Bool) -> AnimatedImage {
        self.imageLayout.antialiased = isAntialiased
        return self
    }
}

// Aspect Ratio
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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
        // So, we directly call the implementation detail modifier instead
        // Fired Radar: FB7413534
        self.imageLayout.aspectRatio = aspectRatio
        self.imageLayout.contentMode = contentMode
        return self.modifier(_AspectRatioLayout(aspectRatio: aspectRatio, contentMode: contentMode))
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
        return self.aspectRatio(aspectRatio.width / aspectRatio.height, contentMode: contentMode)
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
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Total loop count for animated image rendering. Defaults to nil.
    /// - Note: Pass nil to disable customization, use the image itself loop count (`animatedImageLoopCount`) instead
    /// - Parameter loopCount: The animation loop count
    public func customLoopCount(_ loopCount: UInt?) -> AnimatedImage {
        self.imageConfiguration.customLoopCount = loopCount
        return self
    }
    
    /// Provide a max buffer size by bytes. This is used to adjust frame buffer count and can be useful when the decoding cost is expensive (such as Animated WebP software decoding). Default is nil.
    ///
    /// `0` or nil means automatically adjust by calculating current memory usage.
    /// `1` means without any buffer cache, each of frames will be decoded and then be freed after rendering. (Lowest Memory and Highest CPU)
    /// `UInt.max` means cache all the buffer. (Lowest CPU and Highest Memory)
    /// - Parameter bufferSize: The max buffer size
    public func maxBufferSize(_ bufferSize: UInt?) -> AnimatedImage {
        self.imageConfiguration.maxBufferSize = bufferSize
        return self
    }
    
    /// Whehter or not to enable incremental image load for animated image. See `SDAnimatedImageView` for detailed explanation for this.
    /// - Note: If you are confused about this description, open Chrome browser to view some large GIF images with low network speed to see the animation behavior.
    /// Default is true. Set to false to only render the static poster for incremental animated image.
    /// - Parameter incrementalLoad: Whether or not to incremental load
    public func incrementalLoad(_ incrementalLoad: Bool) -> AnimatedImage {
        self.imageConfiguration.incrementalLoad = incrementalLoad
        return self
    }
    
    /// The runLoopMode when animation is playing on. Defaults is `.common`
    ///  You can specify a runloop mode to let it rendering.
    /// - Note: This is useful for some cases, for example, always specify NSDefaultRunLoopMode, if you want to pause the animation when user scroll (for Mac user, drag the mouse or touchpad)
    /// - Parameter runLoopMode: The runLoopMode for animation
    public func runLoopMode(_ runLoopMode: RunLoop.Mode) -> AnimatedImage {
        self.imageConfiguration.runLoopMode = runLoopMode
        return self
    }
    
    /// Whether or not to pause the animation (keep current frame), instead of stop the animation (frame index reset to 0). When `isAnimating` binding value changed to false. Defaults is true.
    /// - Note: For some of use case, you may want to reset the frame index to 0 when stop, but some other want to keep the current frame index.
    /// - Parameter pausable: Whether or not to pause the animation instead of stop the animation.
    public func pausable(_ pausable: Bool) -> AnimatedImage {
        self.imageConfiguration.pausable = pausable
        return self
    }
    
    /// Whether or not to clear frame buffer cache when stopped. Defaults is false.
    /// Note: This is useful when you want to limit the memory usage during frequently visibility changes (such as image view inside a list view, then push and pop)
    /// - Parameter purgeable: Whether or not to clear frame buffer cache when stopped.
    public func purgeable(_ purgeable: Bool) -> AnimatedImage {
        self.imageConfiguration.purgeable = purgeable
        return self
    }
    
    /// Control the animation playback rate. Default is 1.0.
    /// `1.0` means the normal speed.
    /// `0.0` means stopping the animation.
    /// `0.0-1.0` means the slow speed.
    /// `> 1.0` means the fast speed.
    /// `< 0.0` is not supported currently and stop animation. (may support reverse playback in the future)
    /// - Parameter playbackRate: The animation playback rate.
    public func playbackRate(_ playbackRate: Double) -> AnimatedImage {
        self.imageConfiguration.playbackRate = playbackRate
        return self
    }
}

// Completion Handler
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Provide the action when image load fails.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the error during loading. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load fails.
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> AnimatedImage {
        self.imageHandler.failureBlock = action
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: @escaping (PlatformImage) -> Void) -> AnimatedImage {
        self.imageHandler.successBlock = { image, _, _ in
            action(image)
        }
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: @escaping (PlatformImage, SDImageCacheType) -> Void) -> AnimatedImage {
        self.imageHandler.successBlock = { image, _, cacheType in
            action(image, cacheType)
        }
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the loaded image data, the third arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, Data?, SDImageCacheType) -> Void)? = nil) -> AnimatedImage {
        self.imageHandler.successBlock = action
        return self
    }
    
    /// Provide the action when image load progress changes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the received size, the second arg is the total size, all in bytes. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> AnimatedImage {
        self.imageHandler.progressBlock = action
        return self
    }
}

// View Coordinator Handler
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Provide the action when view representable create the native view.
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the context.
    /// - Returns: A view that triggers `action` when view representable create the native view.
    public func onViewCreate(perform action: ((PlatformView, Context) -> Void)? = nil) -> AnimatedImage {
        self.imageHandler.viewCreateBlock = action
        return self
    }
    
    /// Provide the action when view representable update the native view.
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the context.
    /// - Returns: A view that triggers `action` when view representable update the native view.
    public func onViewUpdate(perform action: ((PlatformView, Context) -> Void)? = nil) -> AnimatedImage {
        self.imageHandler.viewUpdateBlock = action
        return self
    }
    
    /// Provide the action when view representable destroy the native view
    /// - Parameter action: The action to perform. The first arg is the native view. The seconds arg is the coordinator (with userInfo).
    /// - Returns: A view that triggers `action` when view representable destroy the native view.
    public static func onViewDestroy(perform action: ((PlatformView, Coordinator) -> Void)? = nil) {
        self.viewDestroyBlock = action
    }
}

// Web Image convenience, based on UIKit/AppKit API
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Associate a placeholder when loading image with url
    /// - Parameter content: A view that describes the placeholder.
    /// - note: The differences between this and placeholder image, it's that placeholder image replace the image for image view, but this modify the View Hierarchy to overlay the placeholder hosting view
    public func placeholder<T>(@ViewBuilder content: () -> T) -> AnimatedImage where T : View {
        #if os(macOS)
        let hostingView = NSHostingView(rootView: content())
        #else
        let hostingView = _UIHostingView(rootView: content())
        #endif
        self.imageConfiguration.placeholderView = hostingView
        return self
    }
    
    /// Associate a placeholder image when loading image with url
    /// - Parameter content: A view that describes the placeholder.
    public func placeholder(_ image: PlatformImage?) -> AnimatedImage {
        self.imageConfiguration.placeholder = image
        return self
    }
    
    /// Associate a indicator when loading image with url
    /// - Note: If you do not need indicator, specify nil. Defaults to nil
    /// - Parameter indicator: indicator, see more in `SDWebImageIndicator`
    public func indicator(_ indicator: SDWebImageIndicator?) -> AnimatedImage {
        self.imageConfiguration.indicator = indicator
        return self
    }
    
    /// Associate a transition when loading image with url
    /// - Note: If you specify nil, do not do transition. Defautls to nil.
    /// - Parameter transition: transition, see more in `SDWebImageTransition`
    public func transition(_ transition: SDWebImageTransition?) -> AnimatedImage {
        self.imageConfiguration.transition = transition
        return self
    }
}

// Indicator
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnimatedImage {
    
    /// Associate a indicator when loading image with url
    /// - Parameter indicator: The indicator type, see `Indicator`
    public func indicator<T>(_ indicator: Indicator<T>) -> some View where T : View {
        return self.modifier(IndicatorViewModifier(reporter: self.imageLoading, indicator: indicator))
    }
    
    /// Associate a indicator when loading image with url, convenient method with block
    /// - Parameter content: A view that describes the indicator.
    public func indicator<T>(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<Double>) -> T) -> some View where T : View {
        return indicator(Indicator(content: content))
    }
}

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
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

#endif
