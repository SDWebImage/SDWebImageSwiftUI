# SDWebImageSwiftUI

[![CI Status](https://travis-ci.org/SDWebImage/SDWebImageSwiftUI.svg?branch=master)](https://travis-ci.org/SDWebImage/SDWebImageSwiftUI)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageSwiftUI.svg)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![License](https://img.shields.io/cocoapods/l/SDWebImageSwiftUI.svg)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageSwiftUI.svg)](https://cocoapods.org/pods/SDWebImageSwiftUI)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![codecov](https://codecov.io/gh/SDWebImage/SDWebImageSwiftUI/branch/master/graph/badge.svg)](https://codecov.io/gh/SDWebImage/SDWebImageSwiftUI)

## What's for

SDWebImageSwiftUI is a SwiftUI image loading framework, which based on [SDWebImage](https://github.com/SDWebImage/SDWebImage).

It brings all your favorite features from SDWebImage, like async image loading, memory/disk caching, animated image playback and performances.

The framework provide the different View structs, which API match the SwiftUI framework guideline. If you're familiar with `Image`, you'll find it easy to use `WebImage` and `AnimatedImage`.

## Features

Since SDWebImageSwiftUI is built on top of SDWebImage, it provide both the out-of-box features as well as advanced powerful features you may want in real world Apps. Check our [Wiki](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage) when you need:

- [x] Animated Image full-stack solution, with balance of CPU && RAM
- [x] Progressive image loading, with animation support
- [x] Reusable download, never request single URL twice
- [x] URL Request / Response Modifier, provide custom HTTP Header
- [x] Image Transformer, apply corner radius or CIFilter
- [x] Multiple caches system, query from different source
- [x] Multiple loaders system, load from different resource

You can also get all benefits from the existing community around with SDWebImage. You can have massive image format support (GIF/APNG/WebP/HEIF/AVIF/SVG/PDF) via [Coder Plugins](https://github.com/SDWebImage/SDWebImage/wiki/Coder-Plugin-List), PhotoKit support via [SDWebImagePhotosPlugin](https://github.com/SDWebImage/SDWebImagePhotosPlugin), Firebase integration via [FirebaseUI](https://github.com/firebase/FirebaseUI-iOS), etc.

Besides all these features, we do optimization for SwiftUI, like Binding, View Modifier, using the same design pattern to become a good SwiftUI citizen.

## Version

This framework is under heavily development, it's recommended to use [the latest release](https://github.com/SDWebImage/SDWebImageSwiftUI/releases) as much as possible (including SDWebImage dependency).

This framework follows [Semantic Versioning](https://semver.org/). Each source-break API changes will bump to a major version.

## Changelog

This project use [keep a changelog](https://keepachangelog.com/en/1.0.0/) format to record the changes. Check the [CHANGELOG.md](https://github.com/SDWebImage/SDWebImageSwiftUI/blob/master/CHANGELOG.md) about the changes between versions. The changes will also be updated in Release page.

## Contribution

All issue reports, feature requests, contributions, and GitHub stars are welcomed. Hope for active feedback and promotion if you find this framework useful.

## Requirements

+ Xcode 12+
+ iOS 13+
+ macOS 10.15+
+ tvOS 13+
+ watchOS 6+
+ Swift 5.2+

## SwiftUI 2.0 Compatibility

iOS 14(macOS 11) introduce the SwiftUI 2.0, which keep the most API compatible, but changes many internal behaviors, which breaks the SDWebImageSwiftUI's function.

From v2.0.0, we adopt SwiftUI 2.0 and iOS 14(macOS 11)'s behavior. You can use `WebImage` and `AnimatedImage` inside the new `LazyVStack`.

```swift
var body: some View {
    ScrollView {
        LazyVStack {
            ForEach(urls, id: \.self) { url in
                AnimatedImage(url: url)
            }
        }
    }
}
```

Note: However, many differences behavior between iOS 13/14's is hard to fixup. Due to maintain issue, in the future release, we will drop the iOS 13 supports and always match SwiftUI 2.0's behavior.


## Installation

#### Swift Package Manager

SDWebImageSwiftUI is available through [Swift Package Manager](https://swift.org/package-manager/).

+ For App integration

For App integration, you should using Xcode 12 or higher, to add this package to your App target. To do this, check [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app?language=objc) about the step by step tutorial using Xcode.

+ For downstream framework

For downstream framework author, you should create a `Package.swift` file into your git repo, then add the following line to mark your framework dependent our SDWebImageSwiftUI.

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0")
    ],
)
```

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

## Usage

### Using `WebImage` to load network image

- [x] Supports placeholder and detail options control for image loading as SDWebImage
- [x] Supports progressive image loading (like baseline)
- [x] Supports success/failure/progress changes event for custom handling
- [x] Supports indicator with activity/progress indicator and customization
- [x] Supports built-in animation and transition, powered by SwiftUI
- [x] Supports animated image as well!

```swift
var body: some View {
    WebImage(url: URL(string: "https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic"))
    // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
    .onSuccess { image, data, cacheType in
        // Success
        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
    }
    .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
    .placeholder(Image(systemName: "photo")) // Placeholder Image
    // Supports ViewBuilder as well
    .placeholder {
        Rectangle().foregroundColor(.gray)
    }
    .indicator(.activity) // Activity Indicator
    .transition(.fade(duration: 0.5)) // Fade Transition with duration
    .scaledToFit()
    .frame(width: 300, height: 300, alignment: .center)
}
```

Note: This `WebImage` using `Image` for internal implementation, which is the best compatible for SwiftUI layout and animation system. But unlike SwiftUI's `Image` which does not support animated image or vector image, `WebImage` supports animated image as well (by defaults from v2.0.0).

However, The `WebImage` animation provide simple common use case, so it's still recommend to use `AnimatedImage` for advanced controls like progressive animation rendering, or vector image rendering.

```swift
@State var isAnimating: Bool = true
var body: some View {
    WebImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"), isAnimating: $isAnimating)) // Animation Control, supports dynamic changes
    // The initial value of binding should be true
    .customLoopCount(1) // Custom loop count
    .playbackRate(2.0) // Playback speed rate
    .playbackMode(.bounce) // Playback normally to the end, then reversely back to the start
    // `WebImage` supports advanced control just like `AnimatedImage`, but without the progressive animation support
}
```

Note: For indicator, you can custom your own as well. For example, iOS 14/watchOS 7 introduce the new `ProgressView`, which can replace our built-in `ProgressIndicator/ActivityIndicator` (where watchOS does not provide).

```swift
WebImage(url: url)
.indicator {
    Indicator { _, _ in
        ProgressView()
    }
}
```

### Using `AnimatedImage` to play animation

- [x] Supports network image as well as local data and bundle image
- [x] Supports animated image format as well as vector image format
- [x] Supports animated progressive image loading (like web browser)
- [x] Supports animation control using the SwiftUI Binding
- [x] Supports indicator and transition, powered by SDWebImage and Core Animation
- [x] Supports advanced control like loop count, playback rate, buffer size, runloop mode, etc
- [x] Supports coordinate with native UIKit/AppKit view

```swift
var body: some View {
    Group {
        AnimatedImage(url: URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif"))
        // Supports options and context, like `.progressiveLoad` for progressive animation loading
        .onFailure { error in
            // Error
        }
        .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
        .placeholder(UIImage(systemName: "photo")) // Placeholder Image
        // Supports ViewBuilder as well
        .placeholder {
            Circle().foregroundColor(.gray)
        }
        .indicator(SDWebImageActivityIndicator.medium) // Activity Indicator
        .transition(.fade) // Fade Transition
        .scaledToFit() // Attention to call it on AnimatedImage, but not `some View` after View Modifier (Swift Protocol Extension method is static dispatched)
        
        // Data
        AnimatedImage(data: try! Data(contentsOf: URL(fileURLWithPath: "/tmp/foo.webp")))
        .customLoopCount(1) // Custom loop count
        .playbackRate(2.0) // Playback speed rate
        
        // Bundle (not Asset Catalog)
        AnimatedImage(name: "animation1", isAnimating: $isAnimating)) // Animation control binding
        .maxBufferSize(.max)
        .onViewUpdate { view, context in // Advanced native view coordinate
            // AppKit tooltip for mouse hover
            view.toolTip = "Mouseover Tip"
            // UIKit advanced content mode
            view.contentMode = .topLeft
            // Coordinator, used for Cocoa Binding or Delegate method
            let coordinator = context.coordinator
        }
    }
}
```

Note: `AnimatedImage` supports both image url or image data for animated image format. Which use the SDWebImage's [Animated ImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) for internal implementation. Pay attention that since this base on UIKit/AppKit representable, some advanced SwiftUI layout and animation system may not work as expected. You may need UIKit/AppKit and Core Animation to modify the native view.

Note: `AnimatedImage` some methods like `.transition`, `.indicator` and `.aspectRatio` have the same naming as `SwiftUI.View` protocol methods. But the args receive the different type. This is because `AnimatedImage` supports to be used with UIKit/AppKit component and animation. If you find ambiguity, use full type declaration instead of the dot expression syntax.

Note: some of methods on `AnimatedImage` will return `some View`, a new Modified Content. You'll lose the type related modifier method. For this case, you can either reorder the method call, or use Native View in `.onViewUpdate` for rescue.

```swift
var body: some View {
    AnimatedImage(name: "animation2") // Just for showcase, don't mix them at the same time
    .indicator(SDWebImageProgressIndicator.default) // UIKit indicator component
    .indicator(Indicator.progress) // SwiftUI indicator component
    .transition(SDWebImageTransition.flipFromLeft) // UIKit animation transition
    .transition(AnyTransition.flipFromLeft) // SwiftUI animation transition
}
```

### Which View to choose

Why we have two different View types here, is because of current SwiftUI limit. But we're aimed to provide best solution for all use cases.

If you don't need animated image, prefer to use `WebImage` firstly. Which behaves the seamless as built-in SwiftUI View. If SwiftUI works, it works. If SwiftUI doesn't work, it either :)

If you need simple animated image, use `WebImage`. Which provide the basic animated image support. But it does not support progressive animation rendering, nor vector image, if you don't care about this.

If you need powerful animated image, `AnimatedImage` is the one to choose. Remember it supports static image as well, you don't need to check the format, just use as it. Also, some powerful feature like UIKit/AppKit tint color, vector image, symbol image configuration, tvOS layered image, only available in `AnimatedImage` but not currently in SwfitUI.

But, because `AnimatedImage` use `UIViewRepresentable` and driven by UIKit, currently there may be some small incompatible issues between UIKit and SwiftUI layout and animation system, or bugs related to SwiftUI itself. We try our best to match SwiftUI behavior, and provide the same API as `WebImage`, which make it easy to switch between these two types if needed.

### Use `ImageManager` for your own View type

The `ImageManager` is a class which conforms to Combine's [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) protocol. Which is the core fetching data source of `WebImage` we provided.

For advanced use case, like loading image into the complicated View graph which you don't want to use `WebImage`. You can directly bind your own View type with the Manager.

It looks familiar like `SDWebImageManager`, but it's built for SwiftUI world, which provide the Source of Truth for loading images. You'd better use SwiftUI's `@ObservedObject` to bind each single manager instance for your View instance, which automatically update your View's body when image status changed.

```swift
struct MyView : View {
    @ObservedObject var imageManager: ImageManager
    var body: some View {
        // Your custom complicated view graph
        Group {
            if imageManager.image != nil {
                Image(uiImage: imageManager.image!)
            } else {
                Rectangle().fill(Color.gray)
            }
        }
        // Trigger image loading when appear
        .onAppear { self.imageManager.load() }
        // Cancel image loading when disappear
        .onDisappear { self.imageManager.cancel() }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView(imageManager: ImageManager(url: URL(string: "https://via.placeholder.com/200x200.jpg"))
    }
}
```

### Customization and configuration setup

This framework is based on SDWebImage, which supports advanced customization and configuration to meet different users' demand.

You can register multiple coder plugins for external image format. You can register multiple caches (different paths and config), multiple loaders (URLSession and Photos URLs). You can control the cache expiration date, size, download priority, etc. All in our [wiki](https://github.com/SDWebImage/SDWebImage/wiki/).

The best place to put these setup code for SwiftUI App, it's the `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Add WebP/SVG/PDF support
    SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    SDImageCodersManager.shared.addCoder(SDImagePDFCoder.shared)
    
    // Add default HTTP header
    SDWebImageDownloader.shared.setValue("image/webp,image/apng,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
    
    // Add multiple caches
    let cache = SDImageCache(namespace: "tiny")
    cache.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB memory
    cache.config.maxDiskSize = 50 * 1024 * 1024 // 50MB disk
    SDImageCachesManager.shared.addCache(cache)
    SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
    
    // Add multiple loaders with Photos Asset support
    SDImageLoadersManager.shared.addLoader(SDImagePhotosLoader.shared)
    SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
    return true
}
```

For more information, it's really recommended to check our demo, to learn detailed API usage. You can also have a check at the latest API documentation, for advanced usage.

## Documentation

+ [SDWebImageSwiftUI API documentation](https://sdwebimage.github.io/SDWebImageSwiftUI/)
+ [SDWebImage API documentation](https://sdwebimage.github.io/)

## FAQ

### Common Problems

#### Using Image/WebImage/AnimatedImage in Button/NavigationLink

SwiftUI's `Button` apply overlay to its content (except `Text`) by default, this is common mistake to write code like this, which cause strange behavior:

```swift
// Wrong
Button(action: {
    // Clicked
}) {
    WebImage(url: url)
}
// NavigationLink create Button implicitly
NavigationView {
    NavigationLink(destination: Text("Detail view here")) {
        WebImage(url: url)
    }
}
```

Instead, you must override the `.buttonStyle` to use the plain style, or the `.renderingMode` to use original mode. You can also use the `.onTapGesture` modifier for touch handling. See [How to disable the overlay color for images inside Button and NavigationLink](https://www.hackingwithswift.com/quick-start/swiftui/how-to-disable-the-overlay-color-for-images-inside-button-and-navigationlink)

```swift
// Correct
Button(action: {
    // Clicked
}) {
    WebImage(url: url)
}
.buttonStyle(PlainButtonStyle())
// Or
NavigationView {
    NavigationLink(destination: Text("Detail view here")) {
        WebImage(url: url)
        .renderingMode(.original)
    }
}
```

#### Using for backward deployment and weak linking SwiftUI

SDWebImageSwiftUI supports to use when your App Target has a deployment target version less than iOS 13/macOS 10.15/tvOS 13/watchOS 6. Which will weak linking of SwiftUI(Combine) to allows writing code with available check at runtime.

To use backward deployment, you have to do the follow things:

##### Add weak linking framework

Add `-weak_framework SwiftUI -weak_framework Combine` in your App Target's `Other Linker Flags` build setting. You can also do this using Xcode's `Optional Framework` checkbox, there have the same effect.

You should notice that all the third party SwiftUI frameworks should have this build setting as well, not only just SDWebImageSwiftUI. Or when running on iOS 12 device, it will trigger the runtime dyld error on startup.

##### Backward deployment on iOS 12.1-

For deployment target version below iOS 12.2 (The first version which Swift 5 Runtime bundled in iOS system), you have to change the min deployment target version of SDWebImageSwiftUI. This may take some side effect on compiler's optimization and trigger massive warnings for some frameworks.

However, for iOS 12.2+, you can still keep the min deployment target version to iOS 13, no extra warnings or performance slow down for iOS 13 client.

Because Swift use the min deployment target version to detect whether to link the App bundled Swift runtime, or the System built-in one (`/usr/lib/swift/libswiftCore.dylib`).

+ For CocoaPods user, you can change the min deployment target version in the Podfile via post installer:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0' # version you need
    end
  end
end
```

+ For Carthage user, you can use `carthage update --no-build` to download the dependency, then change the Xcode Project's deployment target version and build the binary framework.

+ For SwiftPM user, you have to use the local dependency (with the Git submodule) to change the deployment target version.

##### Backward deployment on iOS 12.2+

+ For Carthage user, the built binary framework will use [Library Evolution](https://swift.org/blog/abi-stability-and-more/) to support for backward deployment.

+ For CocoaPods user, you can skip the platform version validation in Podfile with:

```ruby
platform :ios, '13.0' # This does not effect your App Target's deployment target version, just a hint for CocoaPods
```

+ For SwiftPM user, SwiftPM does not support weak linking nor Library Evolution, so it can not deployment to iOS 12+ user without changing the min deployment target.
    
##### Add available annotation

Add **all the SwiftUI code** with the available annotation and runtime check, like this:

```swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ...
    if #available(iOS 13, *) {
        window.rootViewController = UIHostingController(rootView: ContentView())
    } else {
        window.rootViewController = ViewController()
    }
    // ...
}

// ViewController.swift
class ViewController: UIViewController {
    var label: UILabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)
        label.text = "Hello World iOS 12!"
        label.sizeToFit()
        label.center = view.center
    }
}

// ContentView.swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct ContentView : View {
    var body: some View {
        Group {
            Text("Hello World iOS 13!")
            WebImage(url: URL(string: "https://i.loli.net/2019/09/24/rX2RkVWeGKIuJvc.jpg"))
        }
    }
}
```

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
3. Use `Swipe Left` (menu button on tvOS) to delete one image url from list.
4. Pinch gesture (Digital Crown on watchOS, play button on tvOS) to zoom-in detail page image.
5. Clear cache and go to detail page to see progressive loading.

## Test

SDWebImageSwiftUI has Unit Test to increase code quality. For SwiftUI, there are no official Unit Test solution provided by Apple.

However, since SwiftUI is State-Based and Attributed-Implemented layout system, there are open source projects who provide the solution:

+ [ViewInspector](https://github.com/nalexn/ViewInspector): Inspect View's runtime attribute value (like `.frame` modifier, `.image` value). We use this to test `AnimatedImage` and `WebImage`. It also allows the inspect to native UIView/NSView, which we use to test `ActivityIndicator` and `ProgressIndicator`.

To run the test:

1. Run `carthage build` on root directory to install the dependency.
2. Open `SDWebImageSwiftUI.xcodeproj`, wait for SwiftPM finishing downloading the test dependency.
3. Choose `SDWebImageSwiftUITests` scheme and start testing.

We've already setup the CI pipeline, each PR will run the test case and upload the test report to [codecov](https://codecov.io/gh/SDWebImage/SDWebImageSwiftUI).

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

## Thanks

- [SDWebImage](https://github.com/SDWebImage/SDWebImage)
- [libwebp](https://github.com/SDWebImage/libwebp-Xcode)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX)
- [Espera](https://github.com/JagCesar/Espera)
- [SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect)
- [ViewInspector](https://github.com/nalexn/ViewInspector)

## License

SDWebImageSwiftUI is available under the MIT license. See the LICENSE file for more info.


