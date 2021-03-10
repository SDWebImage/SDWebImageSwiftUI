import XCTest
import SwiftUI
import ViewInspector
@testable import SDWebImageSwiftUI

extension WebImage : Inspectable {}

class WebImageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWebImageWithStaticURL() throws {
        let expectation = self.expectation(description: "WebImage static url initializer")
        let imageUrl = URL(string: "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png")
        let imageView = WebImage(url: imageUrl)
        let introspectView = imageView.onSuccess { image, data, cacheType in
            #if os(macOS)
            let displayImage = try? imageView.inspect().group().image(0).nsImage()
            #else
            let displayImage = try? imageView.inspect().group().image(0).cgImage()
            #endif
            XCTAssertNotNil(displayImage)
            expectation.fulfill()
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
    
    func testWebImageWithAnimatedURL() throws {
        let expectation = self.expectation(description: "WebImage animated url initializer")
        let imageUrl = URL(string: "https://apng.onevcat.com/assets/elephant.png")
        let binding = Binding<Bool>(wrappedValue: true)
        let imageView = WebImage(url: imageUrl, isAnimating: binding)
        let introspectView = imageView.onSuccess { image, data, cacheType in
            if let animatedImage = image as? SDAnimatedImage {
                XCTAssertTrue(imageView.isAnimating)
                #if os(macOS)
                let displayImage = try? imageView.inspect().group().image(0).nsImage()
                let size = displayImage?.size
                #else
                let displayImage = try? imageView.inspect().group().image(0).cgImage()
                let size = CGSize(width: displayImage?.width ?? 0, height: displayImage?.height ?? 0)
                #endif
                XCTAssertNotNil(displayImage)
                // Check display image should match the animated poster frame
                let posterImage = animatedImage.animatedImageFrame(at: 0)
                XCTAssertEqual(size, posterImage?.size)
                expectation.fulfill()
            } else {
                XCTFail("WebImage animated image invalid")
            }
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
    
    func testWebImageModifier() throws {
        let expectation = self.expectation(description: "WebImage modifier")
        let imageUrl = URL(string: "https://raw.githubusercontent.com/ibireme/YYImage/master/Demo/YYImageDemo/mew_baseline.jpg")
        let imageView = WebImage(url: imageUrl, options: [.progressiveLoad], context: [.imageScaleFactor: 1])
        let introspectView = imageView
        .onSuccess { _, _, _ in
            expectation.fulfill()
        }
        .onFailure { _ in
            XCTFail()
        }
        .onProgress { _, _ in
            
        }
        .placeholder(.init(platformImage: PlatformImage()))
        .placeholder {
            Circle()
        }
        // Image
        .resizable()
        .renderingMode(.original)
        .interpolation(.high)
        .antialiased(true)
        // Animation
        .runLoopMode(.common)
        .customLoopCount(1)
        .maxBufferSize(0)
        .pausable(true)
        .purgeable(true)
        .playbackRate(1)
        // WebImage
        .retryOnAppear(true)
        .cancelOnDisappear(true)
        .indicator(.activity)
        .transition(.fade)
        .animation(.easeInOut)
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
    
    func testWebImageOnSuccessWhenMemoryCacheHit() throws {
        let expectation = self.expectation(description: "WebImage onSuccess when memory cache hit")
        let imageUrl = URL(string: "https://foo.bar/buzz.png")
        let cacheKey = SDWebImageManager.shared.cacheKey(for: imageUrl)
        #if os(macOS)
        let testImage = TestUtils.testImageBundle().image(forResource: "TestImage")
        #else
        let testImage = UIImage(named: "TestImage", in: TestUtils.testImageBundle(), compatibleWith: nil)
        #endif
        SDImageCache.shared.storeImage(toMemory: testImage, forKey: cacheKey)
        let imageView = WebImage(url: imageUrl)
        let introspectView = imageView.onSuccess { image, data, cacheType in
            XCTAssert(cacheType == .memory)
            XCTAssertNotNil(image)
            XCTAssertEqual(image, testImage)
            expectation.fulfill()
        }
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
    
    func testWebImageOnSuccessWhenCacheMiss() throws {
        let expectation = self.expectation(description: "WebImage onSuccess when cache miss")
        let imageUrl = URL(string: "http://via.placeholder.com/100x100.png")
        let cacheKey = SDWebImageManager.shared.cacheKey(for: imageUrl)
        SDImageCache.shared.removeImageFromMemory(forKey: cacheKey)
        SDImageCache.shared.removeImageFromDisk(forKey: cacheKey)
        let imageView = WebImage(url: imageUrl)
        let introspectView = imageView.onSuccess { image, data, cacheType in
            XCTAssert(cacheType == .none)
            XCTAssertNotNil(image)
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
    
    func testWebImageEXIFImage() throws {
        let expectation = self.expectation(description: "WebImage EXIF image url")
        // EXIF 5, Left Mirrored
        let imageUrl = URL(string: "https://raw.githubusercontent.com/recurser/exif-orientation-examples/master/Landscape_5.jpg")
        let imageView = WebImage(url: imageUrl)
        let introspectView = imageView.onSuccess { image, data, cacheType in
            #if os(macOS)
            let displayImage = try? imageView.inspect().group().image(0).nsImage()
            XCTAssertNotNil(displayImage)
            #else
            let displayImage = try? imageView.inspect().group().image(0).cgImage()
            let orientation = try? imageView.inspect().group().image(0).orientation()
            XCTAssertNotNil(displayImage)
            XCTAssertEqual(orientation, .leftMirrored)
            #endif
            expectation.fulfill()
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect()
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        ViewHosting.expel()
    }
}
