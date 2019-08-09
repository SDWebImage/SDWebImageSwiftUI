//
//  ImageManager.swift
//  SDWebImageSwiftUI
//
//  Created by lizhuoli on 2019/8/9.
//  Copyright © 2019 lizhuoli. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImage

class ImageManager : BindableObject {
    var willChange = PassthroughSubject<ImageManager, Never>()
    var didChange = PassthroughSubject<ImageManager, Never>()
    
    private var manager = SDWebImageManager.shared
    private weak var currentOperation: SDWebImageOperation? = nil
    
    var image: Image? {
        willSet {
            willChange.send(self)
        }
        didSet {
            didChange.send(self)
        }
    }
    
    var url: URL
    var options: SDWebImageOptions
    var context: [SDWebImageContextOption : Any]?
    
    init(url: URL, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
        self.options = options
        self.context = context
    }
    
    func load() {
        currentOperation = manager.loadImage(with: url, options: options, context: context, progress: nil) { (image, data, error, cacheType, _, _) in
            if let image = image {
                #if os(macOS)
                self.image = Image(nsImage: image)
                #else
                self.image = Image(uiImage: image)
                #endif
            }
        }
    }
    
    func cancel() {
        currentOperation?.cancel()
    }
    
}
