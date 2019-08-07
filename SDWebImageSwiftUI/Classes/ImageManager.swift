//
//  ImageManager.swift
//  Pods-SDWebImageSwiftUIDemo
//
//  Created by lizhuoli on 2019/8/7.
//

import SwiftUI
import Combine
import SDWebImage

class ImageManager : BindableObject {
    var willChange = PassthroughSubject<ImageManager, Never>()
    var didChange = PassthroughSubject<ImageManager, Never>()
    
    private var manager = SDWebImageManager.shared
    private weak var currentOperation: SDWebImageOperation? = nil
    
    var image: UIImage? {
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
            self.image = image
        }
    }
    
    func cancel() {
        currentOperation?.cancel()
    }
    
}
