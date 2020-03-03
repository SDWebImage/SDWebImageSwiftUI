//
//  Espera.swift
//  Espera
//
//  Created by jagcesar on 2019-12-29.
//  Copyright © 2019 Ambi. All rights reserved.
//

import SwiftUI

public struct RotatingCircleWithGap: View {
    @State private var angle: Double = 270
    @State var isAnimating = false
    private let lineWidth: CGFloat = 2

    var foreverAnimation: Animation {
        Animation.linear(duration: 1)
            .repeatForever(autoreverses: false)
    }

    public init() { }

    public var body: some View {
        Circle()
            .trim(from: 0.15, to: 1)
            .stroke(Color.gray, style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: CGLineJoin.round))
            .rotationEffect((Angle(degrees: self.isAnimating ? 360.0 : 0)))
            .padding(EdgeInsets(top: lineWidth/2, leading: lineWidth/2, bottom: lineWidth/2, trailing: lineWidth/2))
            .animation(foreverAnimation)
            .onAppear {
                self.isAnimating = true
        }
    }
}

private struct LoadingCircle: View {
    let circleColor: Color
    let scale: CGFloat
    private let circleWidth: CGFloat = 8

    var body: some View {
        Circle()
            .fill(circleColor)
            .frame(width: circleWidth, height: circleWidth, alignment: .center)
            .scaleEffect(scale)
    }
}

public struct LoadingFlowerView: View {
    private let animationDuration: Double = 0.6
    private var singleCircleAnimationDuration: Double {
        return animationDuration/3
    }
    private var foreverAnimation: Animation {
        Animation.linear(duration: animationDuration)
            .repeatForever(autoreverses: true)
    }

    @State private var color: Color = .init(white: 0.3)
    @State private var scale: CGFloat = 0.98

    public init() { }

    public var body: some View {
        HStack(spacing: 1) {
            VStack(spacing: 2) {
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation.delay(singleCircleAnimationDuration*5))
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation.delay(singleCircleAnimationDuration*4))
            }
            VStack(alignment: .center, spacing: 1) {
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation)
                LoadingCircle(circleColor: .clear, scale: 1)
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation.delay(singleCircleAnimationDuration*3))
            }
            VStack(alignment: .center, spacing: 2) {
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation.delay(singleCircleAnimationDuration*1))
                LoadingCircle(circleColor: color, scale: scale)
                    .animation(foreverAnimation.delay(singleCircleAnimationDuration*2))
            }
        }
        .onAppear {
            self.color = .white
            self.scale = 1.02
        }
    }
}

private class StretchyShapeModel {
    var forwards = true
}

extension StretchyShape {
    enum Side {
        case front, back
    }
    
    enum Mode {
        case lagged, stretchy
    }
}

private struct StretchyShape: Shape {
    
    var progress: Double
    var mode: Mode
    init(progress: Double, mode: Mode = .lagged) {
        self.progress = progress
        self.mode = mode
    }
    
    private var model = StretchyShapeModel()
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            addSide(.back, to: &path, rect: rect)
            addSide(.front, to: &path, rect: rect)
            
            if progress >= 1 {
                model.forwards.toggle()
            }
        }
    }
    
    var animatableData: Double {
        set { progress = newValue }
        get { progress }
    }
    
    private func easeInOutQuad(_ x: CGFloat) -> CGFloat {
        if x <= 0.5 {
            return pow(x, 2) * 2
        }
        
        let x = x - 0.5
        return 2 * x * (1 - x) + 0.5
    }
    
    private func addSide(_ side: Side, to path: inout Path, rect: CGRect) {
        let lag = 0.1
        
        let laggedProgress: CGFloat
        let startAngle: Angle
        let endAngle: Angle
        switch side {
            case .front:
                laggedProgress = CGFloat(progress + lag)
                startAngle = Angle(degrees: 90)
                endAngle = Angle(degrees: -90)
            case .back:
                if mode == .stretchy {
                    laggedProgress = 0
                } else {
                    laggedProgress = CGFloat(progress - lag)
                }
                startAngle = Angle(degrees: -90)
                endAngle = Angle(degrees: 90)
        }
        
        var progress = max(0, min(1, laggedProgress))
        
        if !model.forwards {
            progress = 1 - progress
        }
        
        let radius = rect.height / 2
        let offset = easeInOutQuad(progress) * (rect.width - rect.height)
        
        path.addArc(center: CGPoint(x: radius + offset, y: radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: model.forwards)
    }
}

public struct StretchLoadingView: View {
    
    @State private var progress: Double = 0
    
    public init() { }
    
    public var body: some View {
        StretchyShape(progress: progress)
            .animation(Animation.linear(duration: 0.6).repeatForever(autoreverses: false))
            .onAppear {
                withAnimation {
                    self.progress = 1
                }
        }
    }
}

public struct StretchProgressView: View {
    
    @Binding public var progress: Double
    
    public var body: some View {
        StretchyShape(progress: progress, mode: .stretchy)
        .frame(width: 140, height: 10)
    }
}

struct Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RotatingCircleWithGap()
            LoadingFlowerView()
            StretchLoadingView().frame(width: 60, height: 14)
        }
    }
}
