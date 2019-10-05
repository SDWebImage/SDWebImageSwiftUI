//
//  AppDelegate.swift
//  SDWebImageSwiftUIDemo-macOS
//
//  Created by lizhuoli on 2019/10/5.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Cocoa
import SwiftUI
import SDWebImage
import SDWebImageWebPCoder

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        // Add WebP support
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

