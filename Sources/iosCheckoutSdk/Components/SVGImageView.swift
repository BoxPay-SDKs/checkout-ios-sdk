//
//  SVGImageView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore
import SwiftUI
import WebKit
import SVGKit


struct SVGImageView: View {
    let url: URL
    var fallbackImage: String

    @State private var svgImage: SVGKImage?
    @State private var didFail: Bool = false

    var body: some View {
        Group {
            if let svgImage = svgImage {
                Image(uiImage: svgImage.uiImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else if didFail {
                Image(frameworkAsset: fallbackImage, isTemplate: false)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                ShimmerView(height: 30, width: 30)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            loadSVG()
        }
    }

    private func loadSVG() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let svg = SVGKImage(data: data),
               svg.hasSize() || svg.domDocument != nil { // more defensive check
                svg.size = CGSize(width: 30, height: 30)
                DispatchQueue.main.async {
                    self.svgImage = svg
                }
            } else {
                DispatchQueue.main.async {
                    self.didFail = true
                }
            }
        }
    }

}
