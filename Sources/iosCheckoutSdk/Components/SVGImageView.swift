import SwiftUI
import SDWebImageSwiftUI

struct SVGImageView: View {
    let url: String
    var fallbackImage: String

    @State private var hasFailed = false

    var body: some View {
        ZStack {
            if hasFailed {
                Image(fallbackImage)
                    .resizable()
                    .scaledToFit()
            } else {
                WebImage(url: URL(string: url))
                    .resizable()
                    .onFailure { _ in
                        hasFailed = true
                    }
                    .scaledToFit()
            }
        }
        .frame(width: 30, height: 30)
    }
}
