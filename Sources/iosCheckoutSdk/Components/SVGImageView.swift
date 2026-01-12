import SwiftUI
import Combine
import SDWebImageSwiftUI

struct SVGImageView: View {
    let url: URL
    var fallbackImage: String

    @State private var svgData: Data? = nil
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = true
    @State private var hasError = false

    var body: some View {
        ZStack {
            if isLoading {
                // Shimmer Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("...") // Or a proper Shimmer View
                    )
            } else if hasError {
                // Error State
                Image(fallbackImage)
                    .resizable()
                    .scaleEffect(0.4) // Matches your transform: [{ scale: 0.4 }]
            } else {
                if let uiImage = uiImage {
                    // 1. Render Extracted Base64 PNG
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else if let svgData = svgData {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(width: 32, height: 32)
        .onAppear {
            Task {
                await loadAndProcessSVG()
            }
        }

        
    }

    private func loadAndProcessSVG() async {
        if uiImage == nil && svgData == nil {
            isLoading = true
        }
        hasError = false

        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "InvalidData", code: 0)
            }

            // 1. CHECK FOR HIDDEN PNGs (Like the Visa logo)
            // Regex for: xlink:href="data:image/[^"]+"
            let base64Pattern = "xlink:href=\"(data:image\\/[^\"]+)\""
            if let match = text.range(of: base64Pattern, options: .regularExpression) {
                let fullMatch = String(text[match])
                // Extract just the base64 part
                if let dataUrl = fullMatch.components(separatedBy: "\"").dropFirst().first {
                    if let image = await convertBase64ToImage(dataUrl) {
                        self.uiImage = image
                        self.isLoading = false
                        return
                    }
                }
            }

            // 2. CHECK FOR MISSING VIEWBOX
            var finalSvg = text
            if !finalSvg.contains("viewBox") {
                let widthMatch = extractDimension(from: finalSvg, attribute: "width")
                let heightMatch = extractDimension(from: finalSvg, attribute: "height")

                if let w = widthMatch, let h = heightMatch {
                    // Inject viewBox into the <svg tag
                    finalSvg = finalSvg.replacingOccurrences(
                        of: "<svg ",
                        with: "<svg viewBox=\"0 0 \(w) \(h)\" "
                    )
                }
            }

            self.svgData = finalSvg.data(using: .utf8)
            self.isLoading = false

        } catch {
            print("SVG Load Error: \(error)")
            self.hasError = true
            self.isLoading = false
        }
    }

    // Helper to extract width/height values
    private func extractDimension(from text: String, attribute: String) -> String? {
        let pattern = "\(attribute)=\"([^\"]+)\""
        if let range = text.range(of: pattern, options: .regularExpression) {
            let substring = String(text[range])
            return substring.components(separatedBy: "\"").dropFirst().first
        }
        return nil
    }

    // Helper to convert data:image/png;base64,... to UIImage
    private func convertBase64ToImage(_ base64String: String) async -> UIImage? {
        // Remove "data:image/png;base64," or similar prefix
        let components = base64String.components(separatedBy: ",")
        guard components.count > 1, let pureBase64 = components.last else { return nil }
        
        if let data = Data(base64Encoded: pureBase64) {
            return UIImage(data: data)
        }
        return nil
    }
}
