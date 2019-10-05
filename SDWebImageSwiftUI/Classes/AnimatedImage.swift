/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

#if !os(watchOS)

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
    
    public init(url: URL?, placeholder: PlatformImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.init(url: url, placeholder: placeholder, options: options, context: context, isAnimating: .constant(true))
    }
    
    public init(url: URL?, placeholder: PlatformImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        self.placeholder = placeholder
        self.webOptions = options
        self.webContext = context
        self.imageModel.url = url
    }
    
    public init(name: String, bundle: Bundle? = nil) {
        self.init(name: name, bundle: bundle, isAnimating: .constant(true))
    }

    public init(name: String, bundle: Bundle? = nil, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        #if os(macOS)
        let image = SDAnimatedImage(named: name, in: bundle)
        #else
        let image = SDAnimatedImage(named: name, in: bundle, compatibleWith: nil)
        #endif
        self.imageModel.image = image
    }

    public init(data: Data, scale: CGFloat = 0) {
        self.init(data: data, scale: scale, isAnimating: .constant(true))
    }
    
    public init(data: Data, scale: CGFloat = 0, isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        let image = SDAnimatedImage(data: data, scale: scale)
        self.imageModel.image = image
    }
    
    #if os(macOS)
    public typealias NSViewType = AnimatedImageViewWrapper
    #else
    public typealias UIViewType = AnimatedImageViewWrapper
    #endif
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: AnimatedImageViewWrapper, context: NSViewRepresentableContext<AnimatedImage>) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: AnimatedImageViewWrapper, context: UIViewRepresentableContext<AnimatedImage>) {
        updateView(uiView, context: context)
    }
    #endif
    
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
        if self.isAnimating != view.wrapped.isAnimating {
            if self.isAnimating {
                view.wrapped.startAnimating()
            } else {
                view.wrapped.stopAnimating()
            }
        }
        
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
}

// Layout
extension AnimatedImage {
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> AnimatedImage
    {
        imageLayout.capInsets = capInsets
        imageLayout.resizingMode = resizingMode
        return self
    }

    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> AnimatedImage {
        imageLayout.renderingMode = renderingMode
        return self
    }

    public func interpolation(_ interpolation: Image.Interpolation) -> AnimatedImage {
        imageLayout.interpolation = interpolation
        return self
    }

    public func antialiased(_ isAntialiased: Bool) -> AnimatedImage {
        imageLayout.antialiased = isAntialiased
        return self
    }
    
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> AnimatedImage {
        imageLayout.aspectRatio = aspectRatio
        imageLayout.contentMode = contentMode
        return self
    }

    public func aspectRatio(_ aspectRatio: CGSize, contentMode: ContentMode) -> AnimatedImage {
        var ratio: CGFloat?
        if aspectRatio.width > 0 && aspectRatio.height > 0 {
            ratio = aspectRatio.width / aspectRatio.height
        }
        return self.aspectRatio(ratio, contentMode: contentMode)
    }

    public func scaledToFit() -> AnimatedImage {
        self.aspectRatio(nil, contentMode: .fit)
    }
    
    public func scaledToFill() -> AnimatedImage {
        self.aspectRatio(nil, contentMode: .fill)
    }
}

// AnimatedImage Modifier
extension AnimatedImage {
    public func customLoopCount(_ loopCount: Int?) -> AnimatedImage {
        imageConfiguration.customLoopCount = loopCount
        return self
    }
    
    public func maxBufferSize(_ bufferSize: UInt?) -> AnimatedImage {
        imageConfiguration.maxBufferSize = bufferSize
        return self
    }
    
    public func incrementalLoad(_ incrementalLoad: Bool) -> AnimatedImage {
        imageConfiguration.incrementalLoad = incrementalLoad
        return self
    }
}

// Completion Handler
extension AnimatedImage {
    public func onFailure(perform action: ((Error) -> Void)? = nil) -> AnimatedImage {
        imageModel.failureBlock = action
        return self
    }
    
    public func onSuccess(perform action: ((PlatformImage, SDImageCacheType) -> Void)? = nil) -> AnimatedImage {
        imageModel.successBlock = action
        return self
    }
    
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

#endif
