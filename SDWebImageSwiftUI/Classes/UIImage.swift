//
//  UIImage.swift
//  SDWebImageSwiftUI
//
//  Created by Daniel Barclay on 24/06/2020.
//  Copyright © 2020 SDWebImage. All rights reserved.
//

import UIKit

extension UIImage {
    func removeWhiteBackground() -> UIImage? {
        guard let rawImageRef: CGImage = self.cgImage else {
            return nil
        }

        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        UIGraphicsBeginImageContext(image.size)

        let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking)
        UIGraphicsGetCurrentContext()?.translateBy(x: 0.0, y: image.size.height)
        UIGraphicsGetCurrentContext()?.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsGetCurrentContext()?.draw(maskedImageRef!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    func maskBackground() -> UIImage {
        self.removeWhiteBackground() ?? self
    }
}
