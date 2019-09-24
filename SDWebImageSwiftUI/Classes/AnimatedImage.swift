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
    @Published var image: SDAnimatedImage?
    @Published var url: URL?
}

// Layout Binding Object
final class AnimatedImageLayout : ObservableObject {
    @Published var contentMode: ContentMode = .fill
}

// View
public struct AnimatedImage : ViewRepresentable {
    @ObservedObject var imageModel = AnimatedImageModel()
    @ObservedObject var imageLayout = AnimatedImageLayout()
    
    var webOptions: SDWebImageOptions = []
    var webContext: [SDWebImageContextOption : Any]? = nil
    
    #if os(macOS)
    public typealias NSViewType = SDAnimatedImageView
    #else
    public typealias UIViewType = SDAnimatedImageView
    #endif
    
    #if os(macOS)
    public func makeNSView(context: NSViewRepresentableContext<AnimatedImage>) -> SDAnimatedImageView {
        makeView(context: context)
    }
    
    public func updateNSView(_ nsView: SDAnimatedImageView, context: NSViewRepresentableContext<AnimatedImage>) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> SDAnimatedImageView {
        makeView(context: context)
    }
    
    public func updateUIView(_ uiView: SDAnimatedImageView, context: UIViewRepresentableContext<AnimatedImage>) {
        updateView(uiView, context: context)
    }
    #endif
    
    func makeView(context: ViewRepresentableContext<AnimatedImage>) -> SDAnimatedImageView {
        SDAnimatedImageView()
    }
    
    func updateView(_ view: SDAnimatedImageView, context: ViewRepresentableContext<AnimatedImage>) {
        view.image = imageModel.image
        if let url = imageModel.url {
            view.sd_setImage(with: url, placeholderImage: view.image, options: webOptions, context: webContext)
        }
        
        switch imageLayout.contentMode {
        case .fit:
            #if os(macOS)
            view.imageScaling = .scaleProportionallyUpOrDown
            #else
            view.contentMode = .scaleAspectFit
            #endif
        case .fill:
            #if os(macOS)
            view.imageScaling = .scaleAxesIndependently
            #else
            view.contentMode = .scaleToFill
            #endif
        }
    }
    
    public func image(_ image: SDAnimatedImage?) -> Self {
        imageModel.image = image
        return self
    }
    
    public func imageUrl(_ url: URL?) -> Self {
        imageModel.url = url
        return self
    }
    
    public func scaledToFit() -> Self {
        imageLayout.contentMode = .fit
        return self
    }
    
    public func scaledToFill() -> Self {
        imageLayout.contentMode = .fill
        return self
    }
}

extension AnimatedImage {
    public init(url: URL?, placeholder: SDAnimatedImage? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
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

#endif
