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
    }
    
    func makeUIView(context: Context) -> WKWebView {
        switch content {
        case .remote(let urlString):
//            "http://localhost:5173/item"
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
    
    func add(handler: any WebBridgeMessageHandler) {
        webView.configuration.userContentController.add(
            handler,
            name: handler.channelName
        )
    }
    
    func remove(handler: any WebBridgeMessageHandler) {
        webView.configuration.userContentController
            .removeScriptMessageHandler(forName: handler.channelName)
    }
}

struct WebViewContainer: View {
    var messageHandler: (any WebBridgeMessageHandler)?
    
    @State private var webView: ControllableWebView
    
    init(
        content: WebViewContent,
        messageHandler: (any WebBridgeMessageHandler)? = nil
    ) {
        self.messageHandler = messageHandler
        self.webView = .init(content: content)
    }
    
    var body: some View {
        webView
            .onAppear {
                if let messageHandler {
                    webView.add(handler: messageHandler)
                }
            }
            .onDisappear {
                if let messageHandler {
                    webView.remove(handler: messageHandler)
                }
            }
    }
}
