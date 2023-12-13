/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import Combine
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
    
    /// Current playing frame image
    @Published public var currentFrame: PlatformImage?
    
    /// Current playing frame index
    @Published public var currentFrameIndex: UInt = 0
    
    /// Current playing loop count
    @Published public var currentLoopCount: UInt = 0
    
    var currentAnimatedImage: (PlatformImage & SDAnimatedImageProvider)?
    
    /// Whether current player is valid for playing. This will check the internal player exist or not
    public var isValid: Bool {
        player != nil
    }
    
    /// Current playing status
    public var isPlaying: Bool {
        player?.isPlaying ?? false
    }
    
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
    
    /// Seek to frame and loop count
    public func seekToFrame(at: UInt, loopCount: UInt) {
        player?.seekToFrame(at: at, loopCount: loopCount)
    }
    
    /// Clear the frame buffer
    public func clearFrameBuffer() {
        player?.clearFrameBuffer()
    }
    
    /// Setup the player using Animated Image.
    /// After setup, you can always check `isValid` status, or call `startPlaying` to play the animation.
    /// - Parameter image: animated image
    public func setupPlayer(animatedImage: PlatformImage & SDAnimatedImageProvider) {
        if isValid {
            return
        }
        currentAnimatedImage = animatedImage
        if let imagePlayer = SDAnimatedImagePlayer(provider: animatedImage) {
            imagePlayer.animationFrameHandler = { [weak self] (index, frame) in
                guard let self = self else {
                    return
                }
                if (self.isPlaying) {
                    self.currentFrameIndex = index
                    self.currentFrame = frame
                }
            }
            imagePlayer.animationLoopHandler = { [weak self] (loopCount) in
                guard let self = self else {
                    return
                }
                if (self.isPlaying) {
                    self.currentLoopCount = loopCount
                }
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
        }
    }
}
