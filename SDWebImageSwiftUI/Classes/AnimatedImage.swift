//
//  Image+WebCache.swift
//  SDWebImageSwiftUIDemo
//
//  Created by lizhuoli on 2019/7/26.
//  Copyright © 2019 lizhuoli. All rights reserved.
//

import SwiftUI
import SDWebImage

public struct AnimatedImage: UIViewRepresentable {
    var url: URL?
    var name: String?
    var bundle: Bundle?
    var data: Data?
    var scale: Length = 0
    
    public init(url: URL, placeholder: Image? = nil, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
    }
    
    public init(name: String, bundle: Bundle? = nil) {
        self.name = name
        self.bundle = bundle
    }
    
    public init(data: Data, scale: Length = 0) {
        self.data = data
        self.scale = scale
    }
    
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> SDAnimatedImageView {
        SDAnimatedImageView()
    }
    
    public func updateUIView(_ uiView: SDAnimatedImageView, context: UIViewRepresentableContext<AnimatedImage>) {
        if let url = url {
            uiView.sd_setImage(with: url)
            return
        }
        if let name = name {
            uiView.image = SDAnimatedImage(named: name, in: bundle, compatibleWith: nil)
            return
        }
        if let data = data {
            uiView.image = SDAnimatedImage(data: data, scale: scale)
            return
        }
    }
}
