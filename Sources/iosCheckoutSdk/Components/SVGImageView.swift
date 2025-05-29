import SwiftUI
import WebKit

struct WebSVGView: UIViewRepresentable {
    let url: URL
    @Binding var loadState: SVGImageView.LoadState

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; background: transparent; }
                img { width: 100%; height: 100%; object-fit: contain; }
            </style>
        </head>
        <body>
            <img src="\(url.absoluteString)" />
        </body>
        </html>
        """
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebSVGView

        init(_ parent: WebSVGView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.loadState = .success
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadState = .failure
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.loadState = .failure
        }
    }
}

struct SVGImageView: View {
    let url: URL
    let fallbackImage: String

    @State private var loadState: LoadState = .loading

    enum LoadState {
        case loading
        case success
        case failure
    }

    var body: some View {
        ZStack {
            switch loadState {
            case .loading:
                ShimmerView(height: 30)
            case .success:
                WebSVGView(url: url, loadState: $loadState)
                    .frame(width: 30, height: 30)
            case .failure:
                Image(fallbackImage)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            }
        }
    }
}

