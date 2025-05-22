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
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.delegate = context.coordinator // For zooming

        // Load either a URL or raw HTML
        if let url = url {
            let request = URLRequest(url: url)
            print("🔵 Loading URL: \(url.absoluteString)")
            webView.load(request)
        } else if let html = htmlString {
            print("🔵 Loading HTML content")
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
                print("🟡 Navigating to: \(urlString)")

                // Notify parent of navigation
                parent.onNavigationChange?(urlString)

                // If URL contains "boxpay", trigger dismissal
                if urlString.contains("boxpay") {
                    print("🔴 Dismiss triggered for: \(urlString)")
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

        // Log start of navigation
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("➡️ Started navigation to: \(webView.url?.absoluteString ?? "unknown")")
            if ((webView.url?.absoluteString.contains("boxpay")) != nil) {
                print("🔴 Dismiss triggered for: \(String(describing: webView.url?.absoluteString))")
                DispatchQueue.main.async {
                    self.parent.onDismiss?()
                }
            }
        }

        // Log when navigation finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Finished loading: \(webView.url?.absoluteString ?? "unknown")")
        }

        // Optional: allow zooming by identifying zoomable view
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        // Optional: handle load errors
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Navigation failed: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ Provisional navigation failed: \(error.localizedDescription)")
        }
    }
}
