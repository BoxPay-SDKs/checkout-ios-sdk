////
////  WebViewScreen.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 29/01/25.
////
//
//import SwiftUI
//@preconcurrency import WebKit
//
//struct WebView: UIViewRepresentable {
//    let url: URL
//    var onNavigationChange: ((String) -> Void)? // Called on every URL change
//    var onDismiss: (() -> Void)? // Called when specific condition is met
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        webView.allowsBackForwardNavigationGestures = true // Enable back navigation
//        webView.load(URLRequest(url: url))
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // No need to update dynamically
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//
//        init(_ parent: WebView) {
//            self.parent = parent
//        }
//
//        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//            if let url = navigationAction.request.url?.absoluteString {
//                parent.onNavigationChange?(url)
//                
//                // 🚀 Dismiss when URL contains a specific word
//                if url.contains("boxpay") { 
//                    DispatchQueue.main.async {
//                        self.parent.onDismiss?()
//                    }
//                }
//            }
//            decisionHandler(.allow)
//        }
//    }
//}
//
//
//
//
//
