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
    var configurations: [(Image) -> Image] = []
    
    var placeholder: AnyView?
    var retryOnAppear: Bool = true
    var cancelOnDisappear: Bool = true
    
    @ObservedObject var imageManager: ImageManager
    
    /// A Binding to control the animation. You can bind external logic to control the animation status.
    /// True to start animation, false to stop animation.
    @Binding public var isAnimating: Bool
    
    @State var currentFrame: PlatformImage? = nil
    @State var imagePlayer: SDAnimatedImagePlayer? = nil
    
    var maxBufferSize: UInt?
    var customLoopCount: UInt?
    var runLoopMode: RunLoop.Mode = .common
    var pausable: Bool = true
    var purgeable: Bool = false
    var playbackRate: Double = 1.0
    
    /// Create a web image with url, placeholder, custom options and context.
    /// - Parameter url: The image url
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.init(url: url, options: options, context: context, isAnimating: .constant(false))
    }
    
    /// Create a web image with url, placeholder, custom options and context. Optional can support animated image using Binding.
    /// - Parameter url: The image url
    /// - Parameter options: The options to use when downloading the image. See `SDWebImageOptions` for the possible values.
    /// - Parameter context: A context contains different options to perform specify changes or processes, see `SDWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
    /// - Parameter isAnimating: The binding for animation control. The binding value should be `true` when initialized to setup the correct animated image class. If not, you must provide the `.animatedImageClass` explicitly. When the animation started, this binding can been used to start / stop the animation.
    public init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        var context = context ?? [:]
        // provide animated image class if the initialized `isAnimating` is true, user can still custom the image class if they want
        if isAnimating.wrappedValue {
            if context[.animatedImageClass] == nil {
                context[.animatedImageClass] = SDAnimatedImage.self
            }
        }
        self.imageManager = ImageManager(url: url, options: options, context: context)
    }
    
    public var body: some View {
        // This solve the case when WebImage created with new URL, but `onAppear` not been called, for example, some transaction indeterminate state, SwiftUI :)
        if imageManager.isFirstLoad {
            imageManager.load()
        }
        return Group {
            if imageManager.image != nil {
                if isAnimating && !imageManager.isIncremental {
                    if currentFrame != nil {
                        configure(image: currentFrame!)
                        .onAppear {
                            self.imagePlayer?.startPlaying()
                        }
                        .onDisappear {
                            if self.pausable {
                                self.imagePlayer?.pausePlaying()
                            } else {
                                self.imagePlayer?.stopPlaying()
                            }
                            if self.purgeable {
                                self.imagePlayer?.clearFrameBuffer()
                            }
                        }
                    } else {
                        configure(image: imageManager.image!)
                        .onReceive(imageManager.$image) { image in
                            self.setupPlayer(image: image)
                        }
                    }
                } else {
                    if currentFrame != nil {
                        configure(image: currentFrame!)
                    } else {
                        configure(image: imageManager.image!)
                    }
                }
            } else {
                setupPlaceholder()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear {
                    // Load remote image when first appear
                    if self.imageManager.isFirstLoad {
                        self.imageManager.load()
                        return
                    }
                    guard self.retryOnAppear else { return }
                    // When using prorgessive loading, the new partial image will cause onAppear. Filter this case
                    if self.imageManager.image == nil && !self.imageManager.isIncremental {
                        self.imageManager.load()
                    }
                }
                .onDisappear {
                    guard self.cancelOnDisappear else { return }
                    // When using prorgessive loading, the previous partial image will cause onDisappear. Filter this case
                    if self.imageManager.image == nil && !self.imageManager.isIncremental {
                        self.imageManager.cancel()
                    }
                }
            }
        }
    }
    
    /// Configure the platform image into the SwiftUI rendering image
    func configure(image: PlatformImage) -> some View {
        // Actual rendering SwiftUI image
        let result: Image
        // NSImage works well with SwiftUI, include Vector and EXIF images.
        #if os(macOS)
        result = Image(nsImage: image)
        #else
        // Fix the SwiftUI.Image rendering issue, like when use EXIF UIImage, the `.aspectRatio` does not works. SwiftUI's Bug :)
        // See issue #101
        var cgImage: CGImage?
        // Case 1: Vector Image, draw bitmap image
        if image.sd_isVector {
            // ensure CGImage is nil
            if image.cgImage == nil {
                // draw vector into bitmap with the screen scale (behavior like AppKit)
                #if os(iOS) || os(tvOS)
                let scale = UIScreen.main.scale
                #else
                let scale = WKInterfaceDevice.current().screenScale
                #endif
                UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
                image.draw(at: .zero)
                cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
                UIGraphicsEndImageContext()
            } else {
                cgImage = image.cgImage
            }
        }
        // Case 2: Image with EXIF orientation (only EXIF 5-8 contains bug)
        else if [.left, .leftMirrored, .right, .rightMirrored].contains(image.imageOrientation) {
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
        return configurations.reduce(result) { (previous, configuration) in
            configuration(previous)
        }
    }
    
    /// Placeholder View Support
    func setupPlaceholder() -> some View {
        // Don't use `Group` because it will trigger `.onAppear` and `.onDisappear` when condition view removed, treat placeholder as an entire component
        if let placeholder = placeholder {
            // If use `.delayPlaceholder`, the placeholder is applied after loading failed, hide during loading :)
            if imageManager.options.contains(.delayPlaceholder) && imageManager.isLoading {
                return AnyView(configure(image: .empty))
            } else {
                return placeholder
            }
        } else {
            return AnyView(configure(image: .empty))
        }
    }
    
    /// Animated Image Support
    func setupPlayer(image: PlatformImage?) {
        if imagePlayer != nil {
            return
        }
        if let animatedImage = image as? SDAnimatedImageProvider {
            if let imagePlayer = SDAnimatedImagePlayer(provider: animatedImage) {
                imagePlayer.animationFrameHandler = { (_, frame) in
                    self.currentFrame = frame
                }
                // Setup configuration
                if let maxBufferSize = maxBufferSize {
                    imagePlayer.maxBufferSize = maxBufferSize
                }
                if let customLoopCount = customLoopCount {
                    imagePlayer.totalLoopCount = UInt(customLoopCount)
                }
                imagePlayer.runLoopMode = runLoopMode
                imagePlayer.playbackRate = playbackRate
                
                self.imagePlayer = imagePlayer
                imagePlayer.startPlaying()
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
    ///   - action: The action to perform. The first arg is the loaded image. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: @escaping (PlatformImage) -> Void) -> WebImage {
        let action = action
        self.imageManager.successBlock = { image, _, _ in
            action(image)
        }
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: @escaping (PlatformImage, SDImageCacheType) -> Void) -> WebImage {
        self.imageManager.successBlock = { image, _, cacheType in
            action(image, cacheType)
        }
        return self
    }
    
    /// Provide the action when image load successes.
    /// - Parameters:
    ///   - action: The action to perform. The first arg is the loaded image, the second arg is the loaded image data, the third arg is the cache type loaded from. If `action` is `nil`, the call has no effect.
    /// - Returns: A view that triggers `action` when this image load successes.
    public func onSuccess(perform action: ((PlatformImage, Data?, SDImageCacheType) -> Void)? = nil) -> WebImage {
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
        return self.modifier(IndicatorViewModifier(reporter: imageManager, indicator: indicator))
    }
    
    /// Associate a indicator when loading image with url, convenient method with block
    /// - Parameter content: A view that describes the indicator.
    public func indicator<T>(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<Double>) -> T) -> some View where T : View {
        return indicator(Indicator(content: content))
    }
}

// Animated Image
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WebImage {
    
    /// Total loop count for animated image rendering. Defaults to nil.
    /// - Note: Pass nil to disable customization, use the image itself loop count (`animatedImageLoopCount`) instead
    /// - Parameter loopCount: The animation loop count
    public func customLoopCount(_ loopCount: UInt?) -> WebImage {
        var result = self
        result.customLoopCount = loopCount
        return result
    }
    
    /// Provide a max buffer size by bytes. This is used to adjust frame buffer count and can be useful when the decoding cost is expensive (such as Animated WebP software decoding). Default is nil.
    ///
    /// `0` or nil means automatically adjust by calculating current memory usage.
    /// `1` means without any buffer cache, each of frames will be decoded and then be freed after rendering. (Lowest Memory and Highest CPU)
    /// `UInt.max` means cache all the buffer. (Lowest CPU and Highest Memory)
    /// - Parameter bufferSize: The max buffer size
    public func maxBufferSize(_ bufferSize: UInt?) -> WebImage {
        var result = self
        result.maxBufferSize = bufferSize
        return result
    }
    
    /// The runLoopMode when animation is playing on. Defaults is `.common`
    ///  You can specify a runloop mode to let it rendering.
    /// - Note: This is useful for some cases, for example, always specify NSDefaultRunLoopMode, if you want to pause the animation when user scroll (for Mac user, drag the mouse or touchpad)
    /// - Parameter runLoopMode: The runLoopMode for animation
    public func runLoopMode(_ runLoopMode: RunLoop.Mode) -> WebImage {
        var result = self
        result.runLoopMode = runLoopMode
        return result
    }
    
    /// Whether or not to pause the animation (keep current frame), instead of stop the animation (frame index reset to 0). When `isAnimating` binding value changed to false. Defaults is true.
    /// - Note: For some of use case, you may want to reset the frame index to 0 when stop, but some other want to keep the current frame index.
    /// - Parameter pausable: Whether or not to pause the animation instead of stop the animation.
    public func pausable(_ pausable: Bool) -> WebImage {
        var result = self
        result.pausable = pausable
        return result
    }
    
    /// Whether or not to clear frame buffer cache when stopped. Defaults is false.
    /// Note: This is useful when you want to limit the memory usage during frequently visibility changes (such as image view inside a list view, then push and pop)
    /// - Parameter purgeable: Whether or not to clear frame buffer cache when stopped.
    public func purgeable(_ purgeable: Bool) -> WebImage {
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
    /// - Parameter playbackRate: The animation playback rate.
    public func playbackRate(_ playbackRate: Double) -> WebImage {
        var result = self
        result.playbackRate = playbackRate
        return result
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
