/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import UIKit
import SwiftUI
import SDWebImage
import SDWebImageWebPCoder
import SDWebImageSVGCoder
import SDWebImagePDFCoder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var settings = UserSettings()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(settings)

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        let hostingController = UIHostingController(rootView: contentView)
        window.rootViewController = hostingController
        self.window = window
        window.makeKeyAndVisible()
        
        // Hack here because of SwiftUI's bug, when using `NavigationLink`, the focusable no longer works, so the `onExitCommand` does not get called
        let menuGesture = UITapGestureRecognizer(target: self, action: #selector(handleMenuGesture(_:)))
        menuGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        hostingController.view.addGestureRecognizer(menuGesture)
        
        let playPauseGesture = UITapGestureRecognizer(target: self, action: #selector(handlePlayPauseGesture(_:)))
        playPauseGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
        hostingController.view.addGestureRecognizer(playPauseGesture)
        
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
    
    @objc func handleMenuGesture(_ gesture: UITapGestureRecognizer) {
        switch settings.editMode {
        case .inactive:
            settings.editMode = .active
        case .active:
            settings.editMode = .inactive
        case .transient:
            break
        @unknown default:
            break
        }
    }
    
    @objc func handlePlayPauseGesture(_ gesture: UITapGestureRecognizer) {
        settings.zoomed.toggle()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

