//
//  ContentView.swift
//  SDWebImageSwiftUIDemo
//
//  Created by lizhuoli on 2019/8/7.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    var url: URL?
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic")!)
                .scaledToFit()
                .frame(width: 300, height: 300, alignment: .center)
            AnimatedImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif")!)
//                .scaledToFit() // Apple's Bug ? Custom UIView does not passthrough the `contentMode` from Swift UI layout system into UIKit layout system
                .frame(width: 400, height: 300, alignment: .center)
            AnimatedImage(data: try! Data(contentsOf: URL(fileURLWithPath: "/tmp/foo.webp")))
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
