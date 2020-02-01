import XCTest
import SwiftUI

class TestUtils {
    static var testBundle = Bundle(for: TestUtils.self)
    
    class func testImageBundle() -> Bundle {
        let imagePath = (testBundle.resourcePath! as NSString).appendingPathComponent("Images.bundle")
        return Bundle(path: imagePath)!
    }

    class func testImageData(name: String) -> Data? {
        guard let url = testImageBundle().url(forResource: name, withExtension: nil) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
}
