//
//  WebView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    let url: URL?
    let htmlString: String?
    var onNavigationChange: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        if let url = url {
            webView.load(URLRequest(url: url))
        } else if let html = htmlString {
            webView.loadHTMLString(html, baseURL: nil)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString {
                parent.onNavigationChange?(url)

                if url.contains("boxpay") {
                    DispatchQueue.main.async {
                        self.parent.onDismiss?()
                    }
                }
            }
            decisionHandler(.allow)
        }
    }
}
