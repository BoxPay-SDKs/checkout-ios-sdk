import SwiftUI
import SVGKit

// MARK: - Helper for downloading data
func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

// MARK: - SVGImage View
struct SVGImageView: View {
    let url: URL
    var fallbackImage: String = "placeholder"

    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = true
    @State private var didFail: Bool = false

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                ShimmerView(height: 30, width: 30)
            } else if didFail {
                Image(fallbackImage)
                    .resizable()
            }
        }
        .frame(width: 30, height: 30)
        .clipShape(Circle())
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        getData(from: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.didFail = true
                }
                return
            }

            // Try parsing as SVG
            if let svg = SVGKImage(data: data) {
                svg.size = CGSize(width: 30, height: 30)
                let renderer = UIGraphicsImageRenderer(size: svg.size)
                let rendered = renderer.image { ctx in
                    svg.uiImage.draw(in: CGRect(origin: .zero, size: svg.size))
                }
                DispatchQueue.main.async {
                    self.uiImage = rendered
                }
            } else if let altImage = UIImage(data: data, scale: 1.0) {
                // Fallback to raster formats (PNG, JPEG, etc.)
                DispatchQueue.main.async {
                    self.uiImage = altImage
                }
            } else {
                DispatchQueue.main.async {
                    self.didFail = true
                }
            }
        }
    }
}
