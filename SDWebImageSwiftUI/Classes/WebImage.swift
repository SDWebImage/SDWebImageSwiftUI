/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

public enum WebImagePhase {
    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(Error)

    /// The loaded image, if any.
    ///
    /// If this value isn't `nil`, the image load operation has finished,
    /// and you can use the image to update the view. You can use the image
    /// directly, or you can modify it in some way. For example, you can add
    /// a ``Image/resizable(capInsets:resizingMode:)`` modifier to make the
    /// image resizable.
    public var image: Image? {
        switch self {
        case let .success(image):
            return image
        case .empty, .failure:
            return nil
        }
    }

    /// The error that occurred when attempting to load an image, if any.
    public var error: Error? {
        switch self {
        case .empty, .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}

/// Data Binding Object, only properties in this object can support changes from user with @State and refresh
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
final class WebImageModel : ObservableObject {
    /// URL image
    @Published var url: URL?
    @Published var options: SDWebImageOptions = []
    @Published var context: [SDWebImageContextOption : Any]? = nil
}

/// Completion Handler Binding Object, supports dynamic @State changes
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
final class WebImageHandler: ObservableObject {
    // Completion Handler
    @Published var successBlock: ((PlatformImage, Data?, SDImageCacheType) -> Void)?
    @Published var failureBlock: ((Error) -> Void)?
    @Published var progressBlock: ((Int, Int) -> Void)?
}

/// Configuration Binding Object, supports dynamic @State changes
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
final class WebImageConfiguration: ObservableObject {
    var retryOnAppear: Bool = true
    var cancelOnDisappear: Bool = true
    var maxBufferSize: UInt?
    var customLoopCount: UInt?
    var runLoopMode: RunLoop.Mode = .common
    var pausable: Bool = true
    var purgeable: Bool = false
    var playbackRate: Double = 1.0
    var playbackMode: SDAnimatedImagePlaybackMode = .normal
}

/// A Image View type to load image from url. Supports static/animated image format.
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
public struct WebImage<Content> : View where Content: View {
    var transaction: Transaction
    
    var configurations: [(Image) -> Image] = []
    
    var content: (WebImagePhase) -> Content
    
    /// A Binding to control the animation. You can bind external logic to control the animation status.
    /// True to start animation, false to stop animation.
    @Binding public var isAnimating: Bool
    
    /// A observed object to pass through the image model to manager
    @ObservedObject var imageModel: WebImageModel
    
    /// A observed object to pass through the image handler to manager
    @ObservedObject var imageHandler = WebImageHandler()
    
    /// A observed object to pass through the image configuration to player
    @ObservedObject var imageConfiguration = WebImageConfiguration()
    
    @ObservedObject var indicatorStatus : IndicatorStatus
    
    @StateObject var imagePlayer = ImagePlayer()
    
    @StateObject var imageManager : ImageManager
    
    /// Create a web image with url, placeholder, custom options and context. Optional can support animated image using Binding.
    /// - Parameter url: The image url
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    /// - Parameter isAnimating: The binding for animation control. The binding value should be `true` when initialized to setup the correct animated image class. If not, you must provide the `.animatedImageClass` explicitly. When the animation started, this binding can been used to start / stop the animation.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool> = .constant(true)) where Content == Image {
        self.init(url: url, options: options, context: context, isAnimating: isAnimating) { phase in
            phase.image ?? Image(platformImage: .empty)
        }
    }

    public init<I, P>(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool> = .constant(true), @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: url, options: options, context: context, isAnimating: isAnimating) { phase in
            if let i = phase.image {
                content(i)
            } else {
                placeholder()
            }
        }
    }

    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool> = .constant(true), transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (WebImagePhase) -> Content) {
        self._isAnimating = isAnimating
        var context = context ?? [:]
        // provide animated image class if the initialized `isAnimating` is true, user can still custom the image class if they want
        if isAnimating.wrappedValue {
            if context[.animatedImageClass] == nil {
                context[.animatedImageClass] = SDAnimatedImage.self
            }
        }
        let imageModel = WebImageModel()
        imageModel.url = url
        imageModel.options = options
        imageModel.context = context
        _imageModel = ObservedObject(wrappedValue: imageModel)
        let imageManager = ImageManager()
        _imageManager = StateObject(wrappedValue: imageManager)
        _indicatorStatus = ObservedObject(wrappedValue: imageManager.indicatorStatus)
        
        self.transaction = transaction
        self.content = { phase in
            content(phase)
        }
    }
    
    public var body: some View {
        // Container
        return ZStack {
            // Render Logic for actual animated image frame or static image
            if imageManager.image != nil && imageModel.url == imageManager.currentURL {
                if isAnimating && !imageManager.isIncremental {
                    setupPlayer()
                } else {
                    displayImage()
                }
            } else {
                content((imageManager.error != nil) ? .failure(imageManager.error!) : .empty)
                setupInitialState()
                // Load Logic
                .onAppear {
                    guard self.imageConfiguration.retryOnAppear else { return }
                    // When using prorgessive loading, the new partial image will cause onAppear. Filter this case
                    if self.imageManager.error != nil && !self.imageManager.isIncremental {
                        self.imageManager.load(url: imageModel.url, options: imageModel.options, context: imageModel.context)
                    }
                }
                .onDisappear {
                    guard self.imageConfiguration.cancelOnDisappear else { return }
                    // When using prorgessive loading, the previous partial image will cause onDisappear. Filter this case
                    if self.imageManager.error != nil && !self.imageManager.isIncremental {
                        self.imageManager.cancel()
                    }
                }
            }
        }
    }
    
    /// Configure the platform image into the SwiftUI rendering image
    func configure(image: PlatformImage) -> some View {
        // Actual rendering SwiftUI image
        var result: Image
        // NSImage works well with SwiftUI, include Vector and EXIF images.
        #if os(macOS)
        result = Image(nsImage: image)
        #else
        // Fix the SwiftUI.Image rendering issue, like when use EXIF UIImage, the `.aspectRatio` does not works. SwiftUI's Bug :). See #101
        // Always prefers `Image(decorative:scale:)` but not `Image(uiImage:scale:) to avoid bug on `TabbarItem`. See #175
        var cgImage: CGImage?
        // Case 1: Vector Image, draw bitmap image
        if image.sd_isVector {
            // ensure CGImage is nil
            if image.cgImage == nil {
                // draw vector into bitmap with the screen scale (behavior like AppKit)
                #if os(visionOS)
                let scale = UITraitCollection.current.displayScale
                #elseif os(iOS) || os(tvOS) || os(visionOS)
                let scale = UIScreen.main.scale
                #elseif os(watchOS)
                let scale = WKInterfaceDevice.current().screenScale
                #endif
                UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
                image.draw(at: .zero)
                cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
                UIGraphicsEndImageContext()
            } else {
                cgImage = image.cgImage
            }
        } else {
            // Case 2: EXIF Image and Bitmap Image, prefers CGImage
            cgImage = image.cgImage
        }
        // If we have CGImage, use CGImage based API, else use UIImage based API
        if let cgImage = cgImage {
            let scale = image.scale
            let orientation = image.imageOrientation.toSwiftUI
            result = Image(decorative: cgImage, scale: scale, orientation: orientation)
        } else {
            result = Image(uiImage: image)
        }
        #endif
        
        // Should not use `EmptyView`, which does not respect to the container's frame modifier
        // Using a empty image instead for better compatible
        let i = configurations.reduce(result) { (previous, configuration) in
            configuration(previous)
        }
    
        // Apply view builder
        return content(.success(i))
    }
    
    /// Image Manager status
    func setupManager() {
        self.imageManager.successBlock = self.imageHandler.successBlock
        self.imageManager.failureBlock = self.imageHandler.failureBlock
        self.imageManager.progressBlock = self.imageHandler.progressBlock
        if imageModel.url != imageManager.currentURL {
            imageManager.cancel()
            imageManager.image = nil
            imageManager.imageData = nil
            imageManager.cacheType = .none
            imageManager.error = nil
            imageManager.isIncremental = false
            imageManager.indicatorStatus.isLoading = false
            imageManager.indicatorStatus.progress = 0
        }
    }
    
    /// Container level to resume animation when appear
    func appearAction() {
        self.imagePlayer.startPlaying()
    }
    
    /// Container level to stop animation when disappear
    func disappearAction() {
        if self.imageConfiguration.pausable {
            self.imagePlayer.pausePlaying()
        } else {
            self.imagePlayer.stopPlaying()
        }
        if self.imageConfiguration.purgeable {
            self.imagePlayer.clearFrameBuffer()
        }
    }
    
    /// Static Image Display
    func displayImage() -> some View {
        disappearAction()
        if let currentFrame = imagePlayer.currentFrame {
            return configure(image: currentFrame)
        } else {
            return configure(image: imageManager.image!)
        }
    }
    
    /// Animated Image Support
    func setupPlayer() -> some View {
        let shouldResetPlayer: Bool
        // Image compare should use ===/!==, which is faster than isEqual:
        if let animatedImage = imagePlayer.currentAnimatedImage, animatedImage !== imageManager.image! {
            shouldResetPlayer = true
        } else {
            shouldResetPlayer = false
        }
        if !shouldResetPlayer {
            imagePlayer.startPlaying()
        }
        if let currentFrame = imagePlayer.currentFrame, !shouldResetPlayer {
            // Bind frame index to ID to ensure onDisappear called with sync
            return configure(image: currentFrame)
                .id("\(imageModel.url!):\(imagePlayer.currentFrameIndex)")
            .onAppear {}
        } else {
            return configure(image: imageManager.image!)
                .id("\(imageModel.url!):\(imagePlayer.currentFrameIndex)")
            .onAppear {
                if shouldResetPlayer {
                    // Clear previous status
                    self.imagePlayer.stopPlaying()
                    self.imagePlayer.player = nil
                    self.imagePlayer.currentFrame = nil;
                    self.imagePlayer.currentFrameIndex = 0;
                    self.imagePlayer.currentLoopCount = 0;
                }
                if let animatedImage = imageManager.image as? PlatformImage & SDAnimatedImageProvider {
                    self.imagePlayer.customLoopCount = self.imageConfiguration.customLoopCount
                    self.imagePlayer.maxBufferSize = self.imageConfiguration.maxBufferSize
                    self.imagePlayer.runLoopMode = self.imageConfiguration.runLoopMode
                    self.imagePlayer.playbackMode = self.imageConfiguration.playbackMode
                    self.imagePlayer.playbackRate = self.imageConfiguration.playbackRate
                    // Setup new player
                    self.imagePlayer.setupPlayer(animatedImage: animatedImage)
                    self.imagePlayer.startPlaying()
                }
            }
        }
    }
    
    /// Initial state management (update when imageModel.url changed)
    func setupInitialState() -> some View {
        self.setupManager()
        if (self.imageManager.error == nil) {
            // Load remote image when first appear
            self.imageManager.load(url: imageModel.url, options: imageModel.options, context: imageModel.context)
        }
        return setupPlaceholder()
    }
    
    /// Placeholder View Support
    func setupPlaceholder() -> some View {
        let result = content((imageManager.error != nil) ? .failure(imageManager.error!) : .empty)
        // Custom ID to avoid SwiftUI engine cache the status, and does not call `onAppear` when placeholder not changed (See `ContentView.swift/ContentView2` case)
        // Because we load the image url in placeholder's `onAppear`, it should be called to sync with state changes :)
        return result.id(imageModel.url)
    }
}

// Layout
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
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
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension WebImage {
    
    /// Provide the action when image load fails.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the error during loading. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load fails.
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> WebImage {
        self.imageHandler.failureBlock = action
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the loaded image data, the third arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, Data?, SDImageCacheType) -> Void)? = nil) -> WebImage {
        self.imageHandler.successBlock = action
        return self
    }
    
    /// Provide the action when image load progress changes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the received size, the second arg is the total size, all in bytes. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onProgress(perform action: ((Int, Int) -> Void)? = nil) -> WebImage {
        self.imageHandler.progressBlock = action
        return self
    }
}

// WebImage Modifier
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension WebImage {
    /// Control the behavior to retry the failed loading when view become appears again
    /// - Parameter flag: Whether or not to retry the failed loading
    public func retryOnAppear(_ flag: Bool) -> WebImage {
        self.imageConfiguration.retryOnAppear = flag
        return self
    }
    
    /// Control the behavior to cancel the pending loading when view become disappear again
    /// - Parameter flag: Whether or not to cancel the pending loading
    public func cancelOnDisappear(_ flag: Bool) -> WebImage {
        self.imageConfiguration.cancelOnDisappear = flag
        return self
    }
}

// Indicator
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension WebImage {
    
    /// Associate a indicator when loading image with url
    /// - Parameter indicator: The indicator type, see `Indicator`
    public func indicator<T>(_ indicator: Indicator<T>) -> some View where T : View {
        return self.modifier(IndicatorViewModifier(status: indicatorStatus, indicator: indicator))
    }
    
    /// Associate a indicator when loading image with url, convenient method with block
    /// - Parameter content: A view that describes the indicator.
    public func indicator<T>(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<Double>) -> T) -> some View where T : View {
        return indicator(Indicator(content: content))
    }
}

// Animated Image
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
extension WebImage {
    
    /// Total loop count for animated image rendering. Defaults to nil.
    /// - Note: Pass nil to disable customization, use the image itself loop count (`animatedImageLoopCount`) instead
    /// - Parameter loopCount: The animation loop count
    public func customLoopCount(_ loopCount: UInt?) -> WebImage {
        self.imageConfiguration.customLoopCount = loopCount
        return self
    }
    
    /// Provide a max buffer size by bytes. This is used to adjust frame buffer count and can be useful when the decoding cost is expensive (such as Animated WebP software decoding). Default is nil.
    ///
    /// `0` or nil means automatically adjust by calculating current memory usage.
    /// `1` means without any buffer cache, each of frames will be decoded and then be freed after rendering. (Lowest Memory and Highest CPU)
    /// `UInt.max` means cache all the buffer. (Lowest CPU and Highest Memory)
    /// - Parameter bufferSize: The max buffer size
    public func maxBufferSize(_ bufferSize: UInt?) -> WebImage {
        self.imageConfiguration.maxBufferSize = bufferSize
        return self
    }
    
    /// The runLoopMode when animation is playing on. Defaults is `.common`
    ///  You can specify a runloop mode to let it rendering.
    /// - Note: This is useful for some cases, for example, always specify NSDefaultRunLoopMode, if you want to pause the animation when user scroll (for Mac user, drag the mouse or touchpad)
    /// - Parameter runLoopMode: The runLoopMode for animation
    public func runLoopMode(_ runLoopMode: RunLoop.Mode) -> WebImage {
        self.imageConfiguration.runLoopMode = runLoopMode
        return self
    }
    
    /// Whether or not to pause the animation (keep current frame), instead of stop the animation (frame index reset to 0). When `isAnimating` binding value changed to false. Defaults is true.
    /// - Note: For some of use case, you may want to reset the frame index to 0 when stop, but some other want to keep the current frame index.
    /// - Parameter pausable: Whether or not to pause the animation instead of stop the animation.
    public func pausable(_ pausable: Bool) -> WebImage {
        self.imageConfiguration.pausable = pausable
        return self
    }
    
    /// Whether or not to clear frame buffer cache when stopped. Defaults is false.
    /// Note: This is useful when you want to limit the memory usage during frequently visibility changes (such as image view inside a list view, then push and pop)
    /// - Parameter purgeable: Whether or not to clear frame buffer cache when stopped.
    public func purgeable(_ purgeable: Bool) -> WebImage {
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
    public func playbackRate(_ playbackRate: Double) -> WebImage {
        self.imageConfiguration.playbackRate = playbackRate
        return self
    }
    
    /// Control the animation playback mode. Default is .normal
    /// - Parameter playbackMode: The playback mode, including normal order, reverse order, bounce order and reversed bounce order.
    public func playbackMode(_ playbackMode: SDAnimatedImagePlaybackMode) -> WebImage {
        self.imageConfiguration.playbackMode = playbackMode
        return self
    }
}

#if DEBUG
@available(iOS 14.0, OSX 11.0, tvOS 14.0, watchOS 7.0, *)
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
