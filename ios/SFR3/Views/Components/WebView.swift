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
    let content: WebViewContent
    
    @State var webView: WKWebView
    
    init(content: WebViewContent) {
        self.content = content
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.isInspectable = true
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
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op
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
    
    init(
        content: WebViewContent,
        messageHandlers: [any WebBridgeMessageHandler.SubHandler] = []
    ) {
        self.webView = .init(content: content)
        self.messageHandler = .init(subHandlers: messageHandlers)
    }
    
    var body: some View {
        webView
            .onAppear {
                webView.add(handler: messageHandler)
            }
            .onDisappear {
                webView.remove(handler: messageHandler)
            }
    }
}
