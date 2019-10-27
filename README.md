# SDWebImageSwiftUI

[![CI Status](https://travis-ci.org/SDWebImage/SDWebImageSwiftUI.svg?branch=master)](https://travis-ci.com/SDWebImage/SDWebImageSwiftUI)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![License](https://img.shields.io/cocoapods/l/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageSwiftUI.svg?style=flat)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)

## What's for

SDWebImageSwiftUI is a SwiftUI image loading framework, which based on [SDWebImage](https://github.com/SDWebImage/SDWebImage).

It brings all your favorite features from SDWebImage, like async image loading, memory/disk caching, animated image playback and performances.

Besides all these features, we do optimization for SwiftUI, like Binding, View Modifier, using the same design pattern to become a good SwiftUI citizen.

Note we do not guarantee the public API stable for current status until v1.0 version. Since SwiftUI is a new platform for us. This framework is under development, feature requests, contributions, and GitHub stars are welcomed.

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
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "0.6")
    ],
)
```

## Usage

### Using `WebImage` to load network image

- [x] Supports placeholder and detail options control for image loading as SDWebImage
- [x] Supports success/failure/progress changes event for custom handling
- [x] Supports indicator with activity/progress indicator and customization
- [x] Supports built-in animation and transition, powered by SwiftUI

Note: This `WebImage` using `Image` for internal implementation, which is the best compatible for SwiftUI layout and animation system. But it supports static image format only, because unlike `UIImageView` in UIKit, SwiftUI's `Image` does not support animation.

```swift
var body: some View {
    WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic"))
        .onSuccess { image, cacheType in
            // Success
        }
        .resizable()
        .indicator(.activity) // Activity Indicator
        .animation(.easeInOut(duration: 0.5))
        .transition(.fade) // Fade Transition
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
        .onFailure { error in
            // Error
        }
        .indicator(SDWebImageActivityIndicator.medium) // Activity Indicator
        .transition(.fade) // Fade Transition
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
- [x] Supports indicator and transition, powered by SDWebImage and Core Animation
- [x] Supports advanced control like loop count, incremental load, buffer size
- [x] Supports coordinate with native UIKit/AppKit/WatchKit view

Note: `AnimatedImage` supports both image url or image data for animated image format. Which use the SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) for internal implementation. Pay attention that since this base on UIKit/AppKit representable, some advanced SwiftUI layout and animation system may not work as expected. You may need UIKit/AppKit and Core Animation to modify the native view.

Note: From v0.4.0, `AnimatedImage` supports watchOS as well. However, it's not backed by SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) like iOS/tvOS/macOS. It use some tricks and hacks because of the limitation on current Apple's API. It also use Image/IO decoding system, which means it supports GIF and APNG format only, but not external format like WebP.

## Demo

To run the example using SwiftUI, following the steps:

```
cd Example
pod install
```

Then open the Xcode Workspace to run the demo application.

Since SwiftUI is aimed to support all Apple platforms, our demo does this as well, one codebase including:

+ iOS (iPhone/iPad/Mac Catalyst)
+ macOS
+ tvOS
+ watchOS

Tips:

1. Use `Switch` (right-click on macOS) to switch between `WebImage` and `AnimatedImage`.
2. Use `Reload` (right-click on macOS/force press on watchOS) to clear cache.
3. Use `Swipe` to delete one image item.

## Screenshot

+ iOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-iOS.jpg' height=960 />

+ macOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-macOS.jpg' width=960 />

+ tvOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-tvOS.jpg' width=960 />

+ watchOS Demo

<img src='https://raw.githubusercontent.com/SDWebImage/SDWebImageSwiftUI/master/Example/Screenshot/Demo-watchOS.jpg' width=480 />

## Extra Notes

Besides all above things, this project can also ensure the following function available on Swift platform for SDWebImage itself.

+ SwiftUI compatibility
+ Swift Package Manager integration
+ Swift source code compatibility and Swifty

Which means, this project is one core use case and downstream dependency, which driven SDWebImage itself future development.

## Author

DreamPiggy

## License

SDWebImageSwiftUI is available under the MIT license. See the LICENSE file for more info.


