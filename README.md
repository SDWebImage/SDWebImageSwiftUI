# SDWebImageSwiftUI

[![CI Status](https://travis-ci.org/SDWebImage/SDWebImageSwiftUI.svg?branch=master)](https://travis-ci.com/SDWebImage/SDWebImageSwiftUI)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![License](https://img.shields.io/cocoapods/l/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)

## What's for

This is an experimental project for [SDWebImage](https://github.com/SDWebImage/SDWebImage).

It aims to ensure the following function available for users and try to do some experiments for Swift platform.

+ Swift Package Manager integration
+ SwiftUI compatibility
+ Swift source code compatibility

Note we do not guarantee the public API stable for current status. Since SwiftUI is a new platform for us, we need to investigate the API design.

## Requirements

+ Xcode 11+
+ iOS 13+
+ macOS 10.15+
+ tvOS 13+
+ watchOS 6+
+ Swift 5.1+

## Installation

#### CocoaPods

SDWebImageSwiftUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageSwiftUI'
```

#### Carthage

SDWebImageSwiftUI is available through [Carthage](https://github.com/Carthage/Carthage).

```
github "SDWebImage/SDWebImageSwiftUI"
```

#### Swift Package Manager

SDWebImageSwiftUI is available through [Swift Package Manager](https://swift.org/package-manager/).

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "0.2")
    ],
)
```

## Usage

### Using `WebImage` to load network image

- [x] Supports the placeholder and detail options control for image loading as SDWebImage.
- [x] Supports the success/failure/progress changes event for custom handling.

Note: Unlike `UIImageView` in UIKit, SwiftUI's `Image` does not support animation. This `WebImage` using `Image` for internal implementation and supports static image format only.

```swift
var body: some View {
    WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic"))
        .onSuccess(perform: { (image, cacheType) in
            // Success
        })
        .resizable()
        .scaledToFit()
        .frame(width: 300, height: 300, alignment: .center)
}
```

### Using `AnimatedImage` to play animation

```swift
var body: some View {
    Group {
        // Network
        AnimatedImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"))
        .onFailure(perform: { (error) in
            // Error
        })
        .scaledToFit()
        // Data
        AnimatedImage(data: try! Data(contentsOf: URL(fileURLWithPath: "/tmp/foo.webp")))
        .customLoopCount(1)
        // Bundle (not Asset Catalog)
        AnimatedImage(name: "animation1", isAnimating: $isAnimating)) // Animation control binding
        .maxBufferSize(.max)
    }
}
```

- [x] Supports network image as well as local data and bundle image
- [x] Supports animation control using the SwiftUI Binding
- [x] Supports advanced control like loop count, incremental load, buffer size.

Note: `AnimatedImage` supports both image url or image data for animated image format. Which use the SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) for internal implementation.

## Demo

To run the example using SwiftUI, following the steps:

```
cd Example
pod install
```

Then open the Xcode Workspace to run the demo application. You can run it on iOS and macOS.

## Screenshot

+ iOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-iOS.png' width=960 />

+ macOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-macOS.png' width=960 />

## Author

DreamPiggy

## License

SDWebImageSwiftUI is available under the MIT license. See the LICENSE file for more info.


