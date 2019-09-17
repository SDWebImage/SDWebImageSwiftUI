/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import Combine
import SDWebImage

class ImageManager : ObservableObject {
    
    var objectWillChange = PassthroughSubject<ImageManager, Never>()
    
    private var manager = SDWebImageManager.shared
    private weak var currentOperation: SDWebImageOperation? = nil
    
    var image: Image? {
        willSet {
            objectWillChange.send(self)
        }
    }
    
    var url: URL?
    var options: SDWebImageOptions
    var context: [SDWebImageContextOption : Any]?
    
    init(url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]? = nil) {
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
