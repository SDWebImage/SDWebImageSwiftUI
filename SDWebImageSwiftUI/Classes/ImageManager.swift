/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

class ImageManager : ObservableObject {
    @Published var image: PlatformImage?
    @Published var isLoading: Bool = false
    @Published var isIncremental: Bool = false
    @Published var progress: CGFloat = 0
    
    var manager = SDWebImageManager.shared
    weak var currentOperation: SDWebImageOperation? = nil
    
    var url: URL?
    var options: SDWebImageOptions
    var context: [SDWebImageContextOption : Any]?
    var successBlock: ((PlatformImage, SDImageCacheType) -> Void)?
    var failureBlock: ((Error) -> Void)?
    var progressBlock: ((Int, Int) -> Void)?
    
    init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
        self.url = url
        self.options = options
        self.context = context
    }
    
    func load() {
        if currentOperation != nil {
            return
        }
        self.image = nil
        self.isLoading = true
        currentOperation = manager.loadImage(with: url, options: options, context: context, progress: { [weak self] (receivedSize, expectedSize, _) in
            guard let self = self else {
                return
            }
            let progress: CGFloat
            if (expectedSize > 0) {
                progress = CGFloat(receivedSize) / CGFloat(expectedSize)
            } else {
                progress = 0
            }
            DispatchQueue.main.async {
                self.progress = progress
            }
            self.progressBlock?(receivedSize, expectedSize)
        }) { [weak self] (image, data, error, cacheType, finished, _) in
            guard let self = self else {
                return
            }
            if let image = image {
                self.image = image
            }
            self.isIncremental = !finished
            if finished {
                self.isLoading = false
                self.progress = 1
                if let image = image {
                    self.successBlock?(image, cacheType)
                } else {
                    self.failureBlock?(error ?? NSError())
                }
            }
        }
    }
    
    func cancel() {
        currentOperation?.cancel()
    }
    
}
