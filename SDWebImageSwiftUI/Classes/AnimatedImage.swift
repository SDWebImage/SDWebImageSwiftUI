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
}

// Layout Binding Object
final class AnimatedImageLayout : ObservableObject {
    @Published var contentMode: ContentMode = .fill
    @Published var aspectRatio: CGFloat?
    @Published var renderingMode: Image.TemplateRenderingMode?
    @Published var interpolation: Image.Interpolation?
    @Published var antialiased: Bool = false
}

// View
public struct AnimatedImage : ViewRepresentable {
    @ObservedObject var imageModel = AnimatedImageModel()
    @ObservedObject var imageLayout = AnimatedImageLayout()
    
    var webOptions: SDWebImageOptions = []
    var webContext: [SDWebImageContextOption : Any]? = nil
    
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
    
    func makeView(context: ViewRepresentableContext<AnimatedImage>) -> AnimatedImageViewWrapper {
        AnimatedImageViewWrapper()
    }
    
    func updateView(_ view: AnimatedImageViewWrapper, context: ViewRepresentableContext<AnimatedImage>) {
        view.wrapped.image = imageModel.image
        if let url = imageModel.url {
            view.wrapped.sd_setImage(with: url, placeholderImage: nil, options: webOptions, context: webContext)
        }
        
        layoutView(view, context: context)
    }
    
    func layoutView(_ view: AnimatedImageViewWrapper, context: ViewRepresentableContext<AnimatedImage>) {
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
    
    public func image(_ image: PlatformImage?) -> Self {
        imageModel.image = image
        return self
    }
    
    public func imageUrl(_ url: URL?) -> Self {
        imageModel.url = url
        return self
    }
    
    public func resizable(
        capInsets: EdgeInsets = EdgeInsets(),
        resizingMode: Image.ResizingMode = .stretch) -> AnimatedImage
    {
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

extension AnimatedImage {
    public init(url: URL?, placeholder: PlatformImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.webOptions = options
        self.webContext = context
        self.imageModel.url = url
    }

    public init(name: String, bundle: Bundle? = nil) {
        #if os(macOS)
        let image = SDAnimatedImage(named: name, in: bundle)
        #else
        let image = SDAnimatedImage(named: name, in: bundle, compatibleWith: nil)
        #endif
        self.imageModel.image = image
    }

    public init(data: Data, scale: CGFloat = 0) {
        let image = SDAnimatedImage(data: data, scale: scale)
        self.imageModel.image = image
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
