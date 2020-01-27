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
        let introspectView = imageView.onSuccess { image, cacheType in
            #if os(iOS) || os(tvOS)
            let displayImage = try? imageView.inspect().group().image(0).uiImage()
            #else
            let displayImage = try? imageView.inspect().group().image(0).nsImage()
            #endif
            XCTAssertNotNil(displayImage)
            expectation.fulfill()
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect(WebImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWebImageWithAnimatedURL() throws {
        let expectation = self.expectation(description: "WebImage animated url initializer")
        let imageUrl = URL(string: "http://apng.onevcat.com/assets/elephant.png")
        let binding = Binding<Bool>(wrappedValue: true)
        let imageView = WebImage(url: imageUrl, isAnimating: binding)
        let introspectView = imageView.onSuccess { image, cacheType in
            if let animatedImage = image as? SDAnimatedImage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    XCTAssertTrue(imageView.isAnimating)
                    #if os(iOS) || os(tvOS)
                    let displayImage = try? imageView.inspect().group().image(0).uiImage()
                    #else
                    let displayImage = try? imageView.inspect().group().image(0).nsImage()
                    #endif
                    XCTAssertNotNil(displayImage)
                    // Check display image should match the animated poster frame
                    let posterImage = animatedImage.animatedImageFrame(at: 0)
                    XCTAssertEqual(displayImage?.size, posterImage?.size)
                    expectation.fulfill()
                }
            } else {
                XCTFail("WebImage animated image invalid")
            }
        }.onFailure { error in
            XCTFail(error.localizedDescription)
        }
        _ = try introspectView.inspect(WebImage.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
}
