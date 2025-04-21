//
//  WebView.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import SwiftUI
import WebKit

enum WebViewContent {
    case remote(String),
         local(htmlFile: String, directory: String? = nil)
}

private struct ControllableWebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ControllableWebView
        
        init(_ parent: ControllableWebView) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.onLoadFailed?(error)
        }
        
        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.onLoadFailed?(error)
        }
    }
    
    let content: WebViewContent
    var onLoadFailed: ((Error) -> Void)?
    
    @State var webView: WKWebView
    
    init(content: WebViewContent) {
        self.content = content
        
        webView = WKWebView(
            frame: .zero,
            configuration: {
                let config = WKWebViewConfiguration()
                config.userContentController = WKUserContentController()
                return config
            }()
        )
        webView.isInspectable = true
    }
    
    func makeUIView(context: Context) -> WKWebView {
        switch content {
        case .remote(let urlString):
            webView.load(URLRequest(url: URL(string: urlString)!))
            
        case let .local(htmlFile, directory):
            if let path = Bundle.main.path(
                forResource: htmlFile,
                ofType: "html",
                inDirectory: directory
            ) {
                let url = URL(fileURLWithPath: path)
                let dir = url.deletingLastPathComponent()
                webView.loadFileURL(url, allowingReadAccessTo: dir)
            }
        }
        
        return webView
    }
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        webView.navigationDelegate = coordinator
        return coordinator
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        (webView.navigationDelegate as? Coordinator)?.parent = self
    }
    
    func add(handler: WebBridgeMessageHandler) {
        handler.webView = webView
        webView.configuration.userContentController.add(
            handler, name: WebBridgeMessageHandler.channelName
        )
    }
    
    func remove(handler: WebBridgeMessageHandler) {
        handler.webView = nil
        webView.configuration.userContentController
            .removeScriptMessageHandler(forName: WebBridgeMessageHandler.channelName)
    }
}

struct WebViewContainer: View {
    let messageHandler: WebBridgeMessageHandler
    @State private var webView: ControllableWebView
    @State private var loadFailure: Error?
    
    init(
        content: WebViewContent,
        messageHandlers: [any WebBridgeMessageHandler.SubHandler] = []
    ) {
        self.messageHandler = .init(subHandlers: messageHandlers)
        self.webView = .init(content: content)
    }
    
    var body: some View {
        VStack {
            if let loadFailure {
                Group {
                    Text("Unable to load web view")
                    Text("Reason \(loadFailure.localizedDescription)")
                    Button("Reload") {
                        self.loadFailure = nil
                    }
                }
                .padding()
            } else {
                webView
                    .onAppear {
                        webView.onLoadFailed = {
                            loadFailure = $0
                        }
                        webView.add(handler: messageHandler)
                    }
                    .onDisappear {
                        webView.remove(handler: messageHandler)
                    }
            }
        }
    }
}
