//
//  SVGImageView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 05/02/25.
//


import SVGKit
import SwiftUICore
import SwiftUI
import SVGKit

struct SVGImageView: View {
    let url: String
    @State private var svgImage: SVGKImage?
    
    var body: some View {
        Group {
            if let svgImage = svgImage {
                Image(uiImage: svgImage.uiImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                ProgressView()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            #if DEBUG
            // Disable async loading in preview mode
            if !isPreview {
                loadSVG()
            }
            #endif
        }
    }
    
    private func loadSVG() {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let svg = SVGKImage(data: data) {
                DispatchQueue.main.async {
                    self.svgImage = svg
                }
            }
        }
    }
    
    private var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
}

