/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
class ImageManager : ObservableObject {
    @Published var image: PlatformImage? // loaded image, note when progressive loading, this will published multiple times with different partial image
    @Published var isLoading: Bool = false // whether network is loading or cache is querying, should only be used for indicator binding
    @Published var progress: CGFloat = 0 // network progress, should only be used for indicator binding
    
    var manager: SDWebImageManager
    weak var currentOperation: SDWebImageOperation? = nil
    var isSuccess: Bool = false // true means request for this URL is ended forever, load() do nothing
    var isIncremental: Bool = false // true means during incremental loading
    var isFirstLoad: Bool = true // false after first call `load()`
    
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
        if let manager = context?[.customManager] as? SDWebImageManager {
            self.manager = manager
        } else {
            self.manager = .shared
        }
    }
    
    func load() {
        isFirstLoad = false
        if currentOperation != nil {
            return
        }
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
            if let error = error as? SDWebImageError, error.code == .cancelled {
                // Ignore user cancelled
                // There are race condition when quick scroll
                // Indicator modifier disapper and trigger `WebImage.body`
                // So previous View struct call `onDisappear` and cancel the currentOperation
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
                    self.isSuccess = true
                    self.successBlock?(image, cacheType)
                } else {
                    self.failureBlock?(error ?? NSError())
                }
            }
        }
    }
    
    func cancel() {
        currentOperation?.cancel()
        currentOperation = nil
    }
    
}
