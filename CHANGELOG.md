# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.1.3] - 2024-11-06
- Fixed old version compiler does not support automatic self capture in Xcode 14.2 and Swift 5.7.2 #340
- Fix the data race because progress block is called in non-main queue #341

## [3.1.2] - 2024-08-29
- Allows easy to use WebImage with isAnimating default to false and change to true later #333
- Note: This changes WebImage's internal loaded image from `UIImage/NSImage` to `SDAnimatedImage`, which is compatible for `UIImageView/NSImageView`

## [3.1.1] - 2024-07-01
- Fix the transition visual jump between placeholderImage and final image for AnimatedImage #326

## [3.1.0] - 2024-06-27
- Re-implements the aspectRatio support on AnimatedImage, fix issue like cornerRadius #324
- Add Image scale support in WebImage init #323
- Update platform names in `available` attributes #321
- - This is source compatible but binary incompatible version

## [3.0.4] - 2024-04-30
- Trying to move the initial state setup before onAppear to fix the watchOS switching url or any other state issue #316
- This solve a issue in history when sometimes SwiftUI does not trigger the `onAppear` and cause state error, like #312 #314

## [3.0.3] - 2024-04-29
- Added totally empty privacy manifest #315
- People who facing the issue because of Privacy Manifest declaration during ITC validation can try this version

## [3.0.2] - 2024-03-27
- Fix the assert crash then when using Data/Name in AnimatedImage #309

## [3.0.1] - 2024-03-18
- Fix the issue for WebImage/AnimatedImage when url is nil will not cause the reloading #304

## [3.0.0] - 2024-03-09
- This is the first release for 3.x version. Bump the min deplouyment from SwiftUI 1.0 to 2.0 (means iOS 14/macOS 11/tvOS 14/watchOS 7/visionOS 1)
- Fix AnimatedImage aspectRatio issue when ratio is nil #301
- Upgrade to support visionOS on CocoaPods #298

## [3.0.0-beta.3] - 2023-12-04

### Changed
- Update the AnimatedImage API to expose the SDAnimatedImageView #285
- Fix the AnimatedImgae rendering mode about compatible with SDWebImage 5.18+

## [3.0.0-beta.2] - 2023-10-21

### Changed
- Update the WebImage API to match SwiftUI.AsyncImage #275 @Kyle-Ye 
- Allows to use UIImage/NSImage as defaults when init the AnimatedImage with JPEG data #277

### Removed
- `WebImage.placeholder<T>(@ViewBuilder content: () -> T) -> WebImage`
- `WebImage.placeholder(_ image: Image) -> WebImage`
- `AnimatedImage.placeholder<T>(@ViewBuilder content: () -> T) -> AnimatedImage`
- `AnimatedImage.placeholder(_ image: PlatformImage) -> AnimatedImage`

## [3.0.0-beta] - 2023-09-02

### Added
- (Part 1) Support compile for visionOS (no package manager support) #267

### Changed

- Drop iOS 13/macOS 10.15/tvOS 13/watchOS 6 support #250
- ProgressIndicator and ActivityIndicator is removed. Use `ProgressView` instead
- Availability is changed to iOS 14/macOS 11/tvOS 11/watchOS 7
- Embed `SwiftUIBackports` dependency is removed.

## [2.2.3] - 2023-04-32
- Fix the issue that Static Library + Library Evolution cause the build issue on Swift 5.8 #263

## [2.2.2] - 2022-12-27

### Fixed
- Fix the bug that isAnimating control does not works on WebImage #251
- Note you should upgrade the SDWebImage 5.14.3+, or this may cause extra Xcode 14's runtime warning (function is unaffected)

## [2.2.1] - 2022-09-23

### Fixed

- Fix the nil url always returns Error will cause infinity onAppear call and image manager to load, which waste CPU #235
- Fix the case which sometimes the player does not stop when WebImage it out of screen #236
- Al v2.2.0 users are recommended to update

## [2.2.0] - 2022-09-22

### Fixed

- Fix iOS 13 compatibility #232
- Fix WebImage/Animated using @State to publish changes
- Al v2.1.0 users are recommended to update

### Changed
- ImageManager API changes. The init method has no args, use `load(url:options:context:)` instead

## [2.1.0] - 2022-09-15

### Fixed

- Refactor WebImage/AnimatedImage using SwiftUIBackports and StateObject #227
- Fix iOS 16 undefined behavior warnings because of Publishing changes from within view updates.
- Fix iOS 14+ WebImage behavior using `@StateObject` (and backport on iOS 13)

### Changed

- The `IndicatorReportable` is misused and removed. Use `IndicatorStatus` instead.
- Deprecate iOS 13 support, this may be the last version to support iOS 13.

## [2.0.2] - 2021-03-10

### Fixed
- Fix the issue that using `Image(uiImage:)` will result wrong rendering mode in some component like `TabBarItem`, while using `Image(decorative:scale:orientation:)` works well #177

### Changed
- Remove the WebImage placeholder maxWidth/maxHeight modifier, this may break some use case like `TabView`. If user want to use placeholder, limit themselves #178 #175

## [2.0.1] - 2021-02-25
### Fixed
- Fix the rare cases that WebImage will lost animation when visibility changes. #171

## [2.0.0] - 2021-02-23
### Added
- Update with the playbackMode support for `WebImage` and `AnimatedImage` #168
- Update watchOS demo to watchOS 7, remove the custom indicator sample and use `ProgressView` instead #166
- Update the Example to make WebImage animatable by default #160

### Fixed
- Fix the issue sometime the `WebImage` appear/disappear logic wrong. Using UIKit/AppKit to detect the visibility #164
- Fix the leak of WebImage with animation and NavigationLink. #163
- Try to fix the recursive updateView when using AnimatedImage inside `ScrollView/LazyVStack`. Which cause App freeze #162
- Remove the fix for EXIF image in WebImage, which is fixed by Apple in iOS 14 #159

### Changed
- Bump the limit to Xcode 12, because we need new iOS 14+ APIs check #167
- Update the WebImage to defaults animatable #165

### Removed
- Remove the wrong design onSuccess API. Using the full params one instead #169

## [1.5.0] - 2020-06-01
### Added
- Add the convenient API support to use SwiftUI transition with ease-in-out duration #116
- Update the Travis-CI to use Catalina and enable macOS test case #98

## [1.4.0] - 2020-05-07
### Added
- Add the same overload method for onSuccess API, which introduce the image data arg. Keep the source code compatibility #109
- Add the support for image data observable on ImageManager #107

## [1.3.4] - 2020-04-30
### Fixed
- Revert the changes to prefetch the image url from memory cache #106

## [1.3.3] - 2020-04-15
### Fixed
- Try to solve the SwiftUI bug of rendering EXIF UIImage in WebImage, as well as vector images #102
- Now `WebImage` will render the vector images as bitmap version even if you don't provide `.thumbnailPixelSize`. To render real vector images, use `AnimatedImage` instead.

## [1.3.2] - 2020-04-14
### Added
- Automatically import SDWebImage when user write import SDWebImageSwiftUI #100

## [1.3.1] - 2020-04-10
### Fixed
- Fix Carthage support. Do not embed SDWebImage.framework in SDWebImageSwiftUI.framework #97. Thanks @jonkan

## [1.3.0] - 2020-04-05
### Added
- Supports the `placeholder` View Builder API for `AnimatedImage` #94

### Changed
- Upgrade the dependency of SDWebImage 5.7.0 #93

## [1.2.1] - 2020-04-01
### Fixed
- Fix the issue when using `WebImage` with some transition like scaleEffect, each time the new state update will cause unused image fetching #92

## [1.2.0] - 2020-03-29
### Added
- Supports the `delayPlaceholder` for WebImage #91
- `AnimatedImage` little patch - UIKit/AppKit animated image now applied for `resizingMode` #89

### Fixed
- Fix the issue when dealloc `AnimatedImage`'s native View, the window does not exist and cause Crash #90

## [1.1.0] - 2020-03-24
### Added
- `ImageManager` now public. Which allows advanced usage for custom View type. Use `@ObservedObject` to bind the manager with your own View and update the image.

## [1.0.0] - 2020-03-03
### Added
- `WebImage` now supports animation, use `isAnimating` binding value on init methods.
- `WebImage` now supports the detailed animation control options, like `customLoopCount`, `pausable`, `purgeable`, `playbackRate`.
- `AnimatedImage` now supports the indicator with `ViewModifier` as `WebImage`.
- `IndicatorViewModifier` now public.
- `IndicatorReportable` now public.

### Changed
- Indicator's `progress` type now changed from `CGFloat` to `Double`.
- `WebImage.aniamted(_:)` now becomes the `WebImage.init(url:options:context:isAnimating:)` Binding arg, you can use the Binding to control animations as well.
- `AnimatedImage.playBackRate` now becomes `AnimatedImage.playbackRate`
- `AnimatedImage.customLoopCount` now is `UInt` instead of `Int`.
- `AnimatedImage.resizable` modifier now matches the SwiftUI behavior, you must call it or the size will be fixed to image pixel size.

### Removed
- Removed all the description about 0.x version behavior in README.md.
