/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import UIKit
import SDWebImage
import SDWebImageWebPCoder
import SDWebImageSVGCoder
import SDWebImagePDFCoder

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Add WebP/SVG/PDF support
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImagePDFCoder.shared)
        // Dynamic check to support vector format for both WebImage/AnimatedImage
        SDWebImageManager.shared.optionsProcessor = SDWebImageOptionsProcessor { url, options, context in
            var options = options
            if let _ = context?[.animatedImageClass] as? SDAnimatedImage.Type {
                // AnimatedImage supports vector rendering, should not force decode
                options.insert(.avoidDecodeImage)
            }
            return SDWebImageOptionsResult(options: options, context: context)
        }
        return true
    }
}

@main
struct SDWebImageSwiftUIDemo: App {
    // inject into SwiftUI life-cycle via adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
