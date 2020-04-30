# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
