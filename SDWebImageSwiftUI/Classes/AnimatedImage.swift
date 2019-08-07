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
    public var url: URL?
    
    public init(url: URL?) {
        self.url = url
    }
    
    public func makeUIView(context: UIViewRepresentableContext<AnimatedImage>) -> SDAnimatedImageView {
        SDAnimatedImageView()
    }
    
    public func updateUIView(_ uiView: SDAnimatedImageView, context: UIViewRepresentableContext<AnimatedImage>) {
        uiView.sd_setImage(with: url)
    }
}
