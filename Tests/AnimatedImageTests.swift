import XCTest
import SwiftUI
import ViewInspector
import Introspect
@testable import SDWebImageSwiftUI

extension AnimatedImage : Inspectable {}

extension View {
    func introspectAnimatedImage(customize: @escaping (SDAnimatedImageView) -> ()) -> some View {
        return inject(IntrospectionView(
            selector: { introspectionView in
                guard let viewHost = Introspect.findViewHost(from: introspectionView) else {
                    return nil
                }
                return Introspect.previousSibling(containing: SDAnimatedImageView.self, from: viewHost)
            },
            customize: customize
        ))
    }
}

class AnimatedImageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAnimatedImageWithName() throws {
        let expectation = self.expectation(description: "AnimatedImage name initializer")
        let imageView = AnimatedImage(name: "TestImage.gif", bundle: testImageBundle())
        let introspectView = imageView.introspectAnimatedImage { animatedImageView in
            if let animatedImage = animatedImageView.image as? SDAnimatedImage {
                XCTAssertEqual(animatedImage.animatedImageLoopCount, 0)
                XCTAssertEqual(animatedImage.animatedImageFrameCount, 5)
            } else {
                XCTFail("SDAnimatedImageView.image invalid")
            }
            expectation.fulfill()
        }
        _ = try introspectView.inspect(AnimatedImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAnimatedImageWithData() throws {
        let expectation = self.expectation(description: "AnimatedImage data initializer")
        let imageData = try XCTUnwrap(testImageData(name: "TestImageAnimated.apng"))
        let imageView = AnimatedImage(data: imageData)
        let introspectView = imageView.introspectAnimatedImage { animatedImageView in
            if let animatedImage = animatedImageView.image as? SDAnimatedImage {
                XCTAssertEqual(animatedImage.animatedImageLoopCount, 0)
                XCTAssertEqual(animatedImage.animatedImageFrameCount, 101)
            } else {
                XCTFail("SDAnimatedImageView.image invalid")
            }
            expectation.fulfill()
        }
        _ = try introspectView.inspect(AnimatedImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAnimatedImageWithURL() throws {
        let expectation = self.expectation(description: "AnimatedImage url initializer")
        let imageUrl = URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif")
        let imageView = AnimatedImage(url: imageUrl)
        let introspectView = imageView.onSuccess { image, cacheType in
            if let animatedImage = image as? SDAnimatedImage {
                XCTAssertEqual(animatedImage.animatedImageLoopCount, 0)
                XCTAssertEqual(animatedImage.animatedImageFrameCount, 389)
            } else {
                XCTFail("SDAnimatedImageView.image invalid")
            }
            expectation.fulfill()
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect(AnimatedImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAnimatedImageBinding() throws {
        let expectation = self.expectation(description: "AnimatedImage binding control")
        let binding = Binding<Bool>(wrappedValue: true)
        var context: AnimatedImage.Context?
        let imageView = AnimatedImage(name: "TestLoopCount.gif", bundle: testImageBundle(), isAnimating: binding)
            .onViewCreate { _, c in
                context = c
        }
        let introspectView = imageView.introspectAnimatedImage { animatedImageView in
            if let animatedImage = animatedImageView.image as? SDAnimatedImage {
                XCTAssertEqual(animatedImage.animatedImageLoopCount, 1)
                XCTAssertEqual(animatedImage.animatedImageFrameCount, 2)
            } else {
                XCTFail("SDAnimatedImageView.image invalid")
            }
            #if os(iOS) || os(tvOS)
            XCTAssertTrue(animatedImageView.isAnimating)
            #else
            XCTAssertTrue(animatedImageView.animates)
            #endif
            binding.wrappedValue = false
            XCTAssertFalse(binding.wrappedValue)
            XCTAssertFalse(imageView.isAnimating)
            // Currently ViewInspector's @Binding value update does not trigger `UIViewRepresentable.updateUIView`, mock here
            imageView.updateView(animatedImageView.superview as! AnimatedImageViewWrapper, context: context!)
            #if os(iOS) || os(tvOS)
            XCTAssertFalse(animatedImageView.isAnimating)
            #else
            XCTAssertFalse(animatedImageView.animates)
            #endif
            expectation.fulfill()
        }
        _ = try introspectView.inspect(AnimatedImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAnimatedImageModifier() throws {
        let expectation = self.expectation(description: "WebImage modifier")
        let imageUrl = URL(string: "https://assets.sbnation.com/assets/2512203/dogflops.gif")
        AnimatedImage.onViewDestroy { view, coordinator in
            XCTAssert(view.isKind(of: SDAnimatedImageView.self))
            XCTAssertEqual(coordinator.userInfo?["foo"] as? String, "bar")
        }
        let imageView = AnimatedImage(url: imageUrl, options: [.progressiveLoad], context: [.imageScaleFactor: 1])
        let introspectView = imageView
        .onSuccess { _, _ in
            expectation.fulfill()
        }
        .onFailure { _ in
            XCTFail()
        }
        .onProgress { _, _ in
            
        }
        .onViewCreate { view, context in
            XCTAssert(view.isKind(of: SDAnimatedImageView.self))
            context.coordinator.userInfo = ["foo" : "bar"]
        }
        .onViewUpdate { view, context in
            XCTAssert(view.isKind(of: SDAnimatedImageView.self))
            XCTAssertEqual(context.coordinator.userInfo?["foo"] as? String, "bar")
        }
        .placeholder(WebImage.emptyImage)
        .indicator(SDWebImageActivityIndicator.medium)
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
        .transition(.fade)
        .animation(.easeInOut)
        _ = try introspectView.inspect(AnimatedImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
        AnimatedImage.onViewDestroy()
    }
    
    // MARK: Helper
    func testBundle() -> Bundle {
        Bundle(for: type(of: self))
    }
    
    func testImageBundle() -> Bundle {
        let imagePath = (testBundle().resourcePath! as NSString).appendingPathComponent("Images.bundle")
        return Bundle(path: imagePath)!
    }
    
    func testImageData(name: String) -> Data? {
        guard let url = testImageBundle().url(forResource: name, withExtension: nil) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
}
