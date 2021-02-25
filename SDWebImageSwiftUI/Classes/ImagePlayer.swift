/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

/// A Image observable object for handle aniamted image playback. This is used to avoid `@State` update may capture the View struct type and cause memory leak.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ImagePlayer : ObservableObject {
    var player: SDAnimatedImagePlayer?
    
    /// Max buffer size
    public var maxBufferSize: UInt?
    
    /// Custom loop count
    public var customLoopCount: UInt?
    
    /// Animation runloop mode
    public var runLoopMode: RunLoop.Mode = .common
    
    /// Animation playback rate
    public var playbackRate: Double = 1.0
    
    /// Animation playback mode
    public var playbackMode: SDAnimatedImagePlaybackMode = .normal
    
    deinit {
        player?.stopPlaying()
        currentFrame = nil
    }
    
    /// Current playing frame image
    @Published public var currentFrame: PlatformImage?
    
    /// Start the animation
    public func startPlaying() {
        player?.startPlaying()
    }
    
    /// Pause the animation
    public func pausePlaying() {
        player?.pausePlaying()
    }
    
    /// Stop the animation
    public func stopPlaying() {
        player?.stopPlaying()
    }
    
    /// Clear the frame buffer
    public func clearFrameBuffer() {
        player?.clearFrameBuffer()
    }
    
    
    /// Setup the player using Animated Image
    /// - Parameter image: animated image
    public func setupPlayer(image: PlatformImage?) {
        if player != nil {
            return
        }
        if let animatedImage = image as? SDAnimatedImageProvider & PlatformImage {
            if let imagePlayer = SDAnimatedImagePlayer(provider: animatedImage) {
                imagePlayer.animationFrameHandler = { [weak self] (_, frame) in
                    self?.currentFrame = frame
                }
                // Setup configuration
                if let maxBufferSize = maxBufferSize {
                    imagePlayer.maxBufferSize = maxBufferSize
                }
                if let customLoopCount = customLoopCount {
                    imagePlayer.totalLoopCount = customLoopCount
                }
                imagePlayer.runLoopMode = runLoopMode
                imagePlayer.playbackRate = playbackRate
                imagePlayer.playbackMode = playbackMode
                
                self.player = imagePlayer
                
                imagePlayer.startPlaying()
            }
        }
    }
}
