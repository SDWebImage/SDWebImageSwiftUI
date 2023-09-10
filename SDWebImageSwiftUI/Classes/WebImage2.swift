//
//  WebImage2.swift
//
//
//  Created by Kyle on 2023/9/10.
//

import SwiftUI

public struct WebImageEventContext {
    // TODO, Configuration and Information of image
}

struct LoadingState {
    var url: URL?
    var phase: WebImagePhase
    init() {
        url = nil
        phase = .empty
    }
    
    func load() {}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct WebImage2<Content>: View where Content: View {
    var url: URL?
    var scale: CGFloat
    var transaction: Transaction
    var content: (WebImagePhase) -> Content
    
    @State private var loadingState = LoadingState()

    public init(url: URL?, scale: CGFloat = 1) where Content == Image {
        self.init(url: url, scale: scale) { phase in
            phase.image ?? Image("")
        }
    }
    
    public init<I, P>(url: URL?, scale: CGFloat = 1, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: url, scale: scale) { phase in
            if let i = phase.image {
                content(i)
            } else {
                placeholder()
            }
        }
    }

    public init(url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (WebImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = { phase in
            content(phase)
        }
    }
    
    public var body: some View {
        content(loadingState.phase)
            .onAppear {
                load(url)
            }
            .onDisappear {}
            .onChange(of: url) { load($0) }
    }
    
    private func load(_: URL?) {}
}

@available(iOS 13.0, *)
struct LoadingError: Error {}

@available(iOS 13.0, *)
public enum WebImagePhase {
    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(Error)

    public var image: Image? {
        switch self {
        case let .success(image):
            image
        case .empty, .failure:
            nil
        }
    }

    /// The error that occurred when attempting to load an image, if any.
    public var error: Error? {
        switch self {
        case .empty, .success:
            nil
        case let .failure(error):
            error
        }
    }
}
