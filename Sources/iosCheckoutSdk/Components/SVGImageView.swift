import SwiftUI
import SDWebImageSwiftUI

struct SVGImageView: View {
    let url: URL
    let fallbackImage: String

    var body: some View {
        WebImage(url: url)
            .onFailure { error in
                print("Failed to load SVG: \(error.localizedDescription)")
            }
            .placeholder {
                ShimmerView(height: 30, width: 30)
            }
            .resizable()
            .indicator(.activity) // Show loading indicator
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            .scaledToFit()
            .transition(.fade(duration: 0.25))
            .background(
                Image(frameworkAsset : fallbackImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .opacity(0) // fallback hidden by default, WebImage handles fallback internally
            )
    }
}
