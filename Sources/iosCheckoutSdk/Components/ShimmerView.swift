//
//  ShimmerView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI

struct ShimmerView: View {
    var cornerRadius: CGFloat = 10
    var height: CGFloat
    var width: CGFloat = UIScreen.main.bounds.width - 32 // default padding

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)]),
                                 startPoint: .leading,
                                 endPoint: .trailing))
            .frame(width: width, height: height)
            .shimmering() // Custom modifier defined below
    }
}

extension View {
    func shimmering() -> some View {
        self
            .modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.6), .clear]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .blendMode(.plusLighter)
            )
            .mask(content)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    self.phase = 350
                }
            }
    }
}


struct ShimmerPlaceholderScreen: View {
    var body: some View {
        VStack(spacing: 25) {
            ShimmerView(cornerRadius: 0, height: 90)
                .padding(.top, 10)

            ShimmerView(height: 50)
                .padding(.top, 30)

            ForEach(0..<3) { _ in
                ShimmerView(height: 50)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}
