import SwiftUI
@preconcurrency import WebKit

struct WebView: View {
    @Binding var url: String
    @Binding var htmlString: String
    var onDismiss: (() -> Void)?
    var onClickCancel : (() -> Void)
    var brandColor : String
    var onNavigationChange: ((String) -> Void)?

    @State private var showCancelBottomSheet = false

    var body: some View {
        ZStack {
            // 1. The Background (WebView)
            VStack {
                WebViewInner(
                    url: $url,
                    htmlString: $htmlString,
                    onDismiss: onDismiss,
                    onNavigationChange: onNavigationChange,
                    onBackSwipe: {
                        withAnimation {
                            showCancelBottomSheet = true
                        }
                    }
                )
            }
            // Deactivates all touches/scrolling in the WebView when sheet is open
            .disabled(showCancelBottomSheet)
            // Optional: Adds a slight blur to the background
            .blur(radius: showCancelBottomSheet ? 2 : 0)

            // 2. The Dimming Overlay (Scrim)
            if showCancelBottomSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity) // Smooth fade in/out
                    .onTapGesture {
                        // Optional: Close the modal if user taps the dark area
                        withAnimation {
                            showCancelBottomSheet = false
                        }
                    }
            }
        }
        // 3. Your Custom Bottom Sheet
        .bottomSheet(isPresented: $showCancelBottomSheet) {
            VStack(spacing: 20) {
                Text("Cancel Payment?")
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color(hex: "#2D2B32"))
                
                Text("Are you sure you want to cancel the transaction? Your progress will be lost.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color(hex: "#636363"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showCancelBottomSheet = false
                        }
                    }) {
                        Text("No, Continue")
                            .foregroundColor(Color(hex: brandColor))
                            .font(.custom("Poppins-Medium", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showCancelBottomSheet = false
                        onClickCancel()
                    }) {
                        Text("Yes, Cancel")
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex : brandColor))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut, value: showCancelBottomSheet)
    }
}

// Internal Representable to handle WKWebView
private struct WebViewInner: UIViewRepresentable {
    @Binding var url: String
    @Binding var htmlString: String
    var onDismiss: (() -> Void)?
    var onNavigationChange: ((String) -> Void)?
    var onBackSwipe: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // We disable the default browser gesture to intercept it ourselves
        webView.allowsBackForwardNavigationGestures = false
        
        // Add the Edge Swipe Gesture
        let edgePan = UIScreenEdgePanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleEdgePan(_:)))
        edgePan.edges = .left
        webView.addGestureRecognizer(edgePan)

        if !url.isEmpty, let reqUrl = URL(string: url) {
            webView.load(URLRequest(url: reqUrl))
        } else if !htmlString.isEmpty {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewInner
        init(_ parent: WebViewInner) { self.parent = parent }

        @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                parent.onBackSwipe()
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.onNavigationChange?(url.absoluteString)
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if webView.url?.absoluteString.contains("boxpay") == true {
                parent.onDismiss?()
            }
        }
    }
}
