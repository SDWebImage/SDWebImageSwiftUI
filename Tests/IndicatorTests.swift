import XCTest
import SwiftUI
import ViewInspector
import Introspect
@testable import SDWebImageSwiftUI

extension ActivityIndicator : Inspectable {}
extension ProgressIndicator : Inspectable {}

#if os(iOS) || os(tvOS)
typealias ActivityIndicatorViewType = UIActivityIndicatorView
typealias ProgressIndicatorViewType = UIProgressView
#else
typealias ActivityIndicatorViewType = NSProgressIndicator
typealias ProgressIndicatorViewType = NSProgressIndicator
#endif

extension View {
    func introspectActivityIndicator(customize: @escaping (ActivityIndicatorViewType) -> ()) -> some View {
        return inject(IntrospectionView(
            selector: { introspectionView in
                guard let viewHost = Introspect.findViewHost(from: introspectionView) else {
                    return nil
                }
                return Introspect.previousSibling(containing: ActivityIndicatorViewType.self, from: viewHost)
            },
            customize: customize
        ))
    }
    
    func introspectProgressIndicator(customize: @escaping (ProgressIndicatorViewType) -> ()) -> some View {
        return inject(IntrospectionView(
            selector: { introspectionView in
                guard let viewHost = Introspect.findViewHost(from: introspectionView) else {
                    return nil
                }
                return Introspect.previousSibling(containing: ProgressIndicatorViewType.self, from: viewHost)
            },
            customize: customize
        ))
    }
}

class IndicatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        SDImageCache.shared.clear(with: .all)
    }
    
    func testActivityIndicator() throws {
        let expectation = self.expectation(description: "Activity indicator")
        let binding = Binding<Bool>(wrappedValue: true)
        let indicator = ActivityIndicator(binding, style: .medium)
        let introspectView = indicator.introspectActivityIndicator { indicatorView in
            #if os(iOS) || os(tvOS)
            XCTAssertTrue(indicatorView.isAnimating)
            #endif
            binding.wrappedValue = false
            XCTAssertFalse(binding.wrappedValue)
            XCTAssertFalse(indicator.isAnimating)
            #if os(iOS) || os(tvOS)
            indicatorView.stopAnimating()
            #else
            indicatorView.stopAnimation(nil)
            #endif
            #if os(iOS) || os(tvOS)
            XCTAssertFalse(indicatorView.isAnimating)
            #endif
            expectation.fulfill()
        }
        _ = try introspectView.inspect(ActivityIndicator.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testProgressIndicator() throws {
        let expectation = self.expectation(description: "Progress indicator")
        let binding = Binding<Bool>(wrappedValue: true)
        let progress = Binding<CGFloat>(wrappedValue: 0)
        let indicator = ProgressIndicator(binding, progress: progress)
        let introspectView = indicator.introspectProgressIndicator { indicatorView in
            #if os(iOS) || os(tvOS)
            XCTAssertEqual(indicatorView.progress, 0.0)
            #else
            XCTAssertEqual(indicatorView.doubleValue, 0.0)
            #endif
            progress.wrappedValue = 1.0
            XCTAssertEqual(indicator.progress, 1.0)
            #if os(iOS) || os(tvOS)
            indicatorView.setProgress(1.0, animated: true)
            #else
            indicatorView.increment(by: 1.0)
            #endif
            #if os(iOS) || os(tvOS)
            XCTAssertEqual(indicatorView.progress, 1.0)
            #else
            XCTAssertEqual(indicatorView.doubleValue, 1.0)
            #endif
            expectation.fulfill()
        }
        _ = try introspectView.inspect(ProgressIndicator.self)
        ViewHosting.host(view: introspectView)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
}
