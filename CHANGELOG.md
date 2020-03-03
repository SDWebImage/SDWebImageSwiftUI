# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
