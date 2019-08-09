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

public struct AnimatedImage: ViewRepresentable {
    var url: URL?
    var name: String?
    var bundle: Bundle?
    var data: Data?
    var scale: CGFloat = 0
    
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
        if let url = url {
            view.sd_setImage(with: url)
            return
        }
        if let name = name {
            #if os(macOS)
            view.image = SDAnimatedImage(named: name, in: bundle)
            #else
            view.image = SDAnimatedImage(named: name, in: bundle, compatibleWith: nil)
            #endif
            return
        }
        if let data = data {
            view.image = SDAnimatedImage(data: data, scale: scale)
            return
        }
    }
    
    public init(url: URL, placeholder: Image? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
    }
    
    public init(name: String, bundle: Bundle? = nil) {
        self.name = name
        self.bundle = bundle
    }
    
    public init(data: Data, scale: CGFloat = 0) {
        self.data = data
        self.scale = scale
    }
}

#endif
