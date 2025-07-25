//
//  WebView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    let url: String?
    let htmlString: String?
    var onNavigationChange: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.delegate = context.coordinator // For zooming

        // Load either a URL or raw HTML
        if let url = url {
            let request = URLRequest(url: URL(string : url)!)
            webView.load(request)
        } else if let html = htmlString {
            webView.loadHTMLString(html, baseURL: nil)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No dynamic updates required
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Intercept navigations and optionally dismiss
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if let url = navigationAction.request.url {
                let urlString = url.absoluteString

                // Notify parent of navigation
                parent.onNavigationChange?(urlString)

                // If URL contains "boxpay", trigger dismissal
                if urlString.contains("boxpay") {
                    DispatchQueue.main.async {
                        self.parent.onDismiss?()
                    }
                }

                // Open all links in same web view (even if target is nil)
                if navigationAction.targetFrame == nil {
                    webView.load(URLRequest(url: url))
                    decisionHandler(.cancel)
                    return
                }
            }

            decisionHandler(.allow)
        }

        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if ((webView.url?.absoluteString.contains("boxpay")) == true) {
                DispatchQueue.main.async {
                    self.parent.onDismiss?()
                }
            }
        }
    }
}
