//
//  SDWebImageSwiftUI.swift
//  SDWebImageSwiftUI
//
//  Created by lizhuoli on 2019/8/9.
//  Copyright © 2019 lizhuoli. All rights reserved.
//

import Foundation
import SwiftUI

#if !os(watchOS)

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias ViewRepresentableContext = NSViewRepresentableContext
#else
typealias ViewRepresentable = UIViewRepresentable
typealias ViewRepresentableContext = UIViewRepresentableContext
#endif

#endif
