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

## Features

Since SDWebImageSwiftUI is built on top of SDWebImage, it provide both the out-of-box features as well as advanced powerful features you may want in real world Apps. Check our [Wiki](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage) when you need:

- [x] Animated Image full-stack solution, with balance of CPU && RAM
- [x] Progressive image loading, with animation support
- [x] Reusable download, never request single URL twice
- [x] URL Request / Response Modifier, provide custom HTTP Header
- [x] Image Transformer, apply corner radius or CIFilter
- [x] Multiple caches system, query from different source
- [x] Multiple loaders system, load from different resource

You can also get all benefits from the existing community around with SDWebImage. You can have massive image format support (GIF/APNG/WebP/HEIF/AVIF) via [Coder Plugins](https://github.com/SDWebImage/SDWebImage/wiki/Coder-Plugin-List), PhotoKit support via [SDWebImagePhotosPlugin](https://github.com/SDWebImage/SDWebImagePhotosPlugin), Firebase integration via [FirebaseUI](https://github.com/firebase/FirebaseUI-iOS), etc.

Besides all these features, we do optimization for SwiftUI, like Binding, View Modifier, using the same design pattern to become a good SwiftUI citizen.

## Contribution

This framework is under heavily development, it's recommended to use [the latest release](https://github.com/SDWebImage/SDWebImageSwiftUI/releases) as much as possible (including SDWebImage dependency).

Note we do not guarantee the public API stable for current status until v1.0 version, to follow [Semantic Versioning](https://semver.org/).

All issue reports, feature requests, contributions, and GitHub stars are welcomed. Hope for active feedback and promotion if you find this framework useful.

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
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "0.8")
    ],
)
```

## Usage

### Using `WebImage` to load network image

- [x] Supports placeholder and detail options control for image loading as SDWebImage
- [x] Supports progressive image loading (like baseline)
- [x] Supports success/failure/progress changes event for custom handling
- [x] Supports indicator with activity/progress indicator and customization
- [x] Supports built-in animation and transition, powered by SwiftUI

```swift
var body: some View {
    WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic"))
        .onSuccess { image, cacheType in
            // Success
        }
        .resizable() // Resizable like SwiftUI.Image
        .placeholder(Image(systemName: "photo")) // Placeholder Image
        // Supports ViewBuilder as well
        .placeholder {
            Rectangle().foregroundColor(.gray)
        }
        .indicator(.activity) // Activity Indicator
        .animation(.easeInOut(duration: 0.5)) // Animation Duration
        .transition(.fade) // Fade Transition
        .scaledToFit()
        .frame(width: 300, height: 300, alignment: .center)
}
```

Note: This `WebImage` using `Image` for internal implementation, which is the best compatible for SwiftUI layout and animation system. But it supports static image format only, because unlike `UIImageView` in UIKit, SwiftUI's `Image` does not support animation.

### Using `AnimatedImage` to play animation

- [x] Supports network image as well as local data and bundle image
- [x] Supports animated progressive image loading (like web browser)
- [x] Supports animation control using the SwiftUI Binding
- [x] Supports indicator and transition, powered by SDWebImage and Core Animation
- [x] Supports advanced control like loop count, playback rate, buffer size, runloop mode, etc
- [x] Supports coordinate with native UIKit/AppKit/WatchKit view

```swift
var body: some View {
    Group {
        // Network
        AnimatedImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"), options: [.progressiveLoad]) // Progressive Load
        .onFailure { error in
            // Error
        }
        .resizable() // Actually this is not needed unlike SwiftUI.Image
        .placeholder(UIImage(systemName: "photo")) // Placeholder Image
        .indicator(SDWebImageActivityIndicator.medium) // Activity Indicator
        .transition(.fade) // Fade Transition
        .scaledToFit() // Attention to call it on AnimatedImage, but not `some View` after View Modifier
        
        // Data
        AnimatedImage(data: try! Data(contentsOf: URL(fileURLWithPath: "/tmp/foo.webp")))
        .customLoopCount(1) // Custom loop count
        .playbackRate(2.0) // Playback speed rate
        
        // Bundle (not Asset Catalog)
        AnimatedImage(name: "animation1", isAnimating: $isAnimating)) // Animation control binding
        .maxBufferSize(.max)
        .onViewUpdate { view, context in // Advanced native view coordinate
            view.toolTip = "Mouseover Tip"
        }
    }
}
```

Note: `AnimatedImage` supports both image url or image data for animated image format. Which use the SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) for internal implementation. Pay attention that since this base on UIKit/AppKit representable, some advanced SwiftUI layout and animation system may not work as expected. You may need UIKit/AppKit and Core Animation to modify the native view.

Note: From v0.8.0, `AnimatedImage` on watchOS support all features the same as iOS/tvOS/macOS, including Animated WebP rendering, runloop mode, pausable, purgeable, playback rate, etc. It use the SDWebImage's [Animated Player](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-player-530), which is the same backend engine for iOS/tvOS/macOS's Animated ImageView.

Note: From v0.4.0, `AnimatedImage` supports watchOS as well. However, it's not backed by SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) like iOS/tvOS/macOS. It use some tricks and hacks because of the limitation on current Apple's API. It also use Image/IO decoding system, which means it supports GIF and APNG format only, but not external format like Animated WebP.

### Which View to choose

Why we have two different View types here, is because of current SwiftUI limit. But we're aimed to provide best solution for all use cases.

If you don't need animated image, prefer to use `WebImage` firstly. Which behaves the seamless as built-in SwiftUI View. If SwiftUI works, it works.

If you need animated image, `AnimatedImage` is the one to choose. Remember it supports static image as well, you don't need to check the format, just use as it.

But, because `AnimatedImage` use `UIViewRepresentable` and driven by UIKit, currently there may be some small incompatible issues between UIKit and SwiftUI layout and animation system, or bugs related to SwiftUI itself. We try our best to match SwiftUI behavior, and provide the same API as `WebImage`, which make it easy to switch between these two types if needed.

For more information, it's really recommended to check our demo below, to learn detailed API usage.

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

Demo Tips:

1. Use `Switch` (right-click on macOS/force press on watchOS) to switch between `WebImage` and `AnimatedImage`.
2. Use `Reload` (right-click on macOS/force press on watchOS) to clear cache.
3. Use `Swipe` to delete one image item.
4. Clear cache and go to detail page to see progressive loading.

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

[DreamPiggy](https://github.com/dreampiggy)

## License

SDWebImageSwiftUI is available under the MIT license. See the LICENSE file for more info.


