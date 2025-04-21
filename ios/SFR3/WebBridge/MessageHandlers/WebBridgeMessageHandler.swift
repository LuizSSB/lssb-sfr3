//
//  WebBridgeMessageHandler.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import WebKit

class WebBridgeMessageHandler: NSObject, WKScriptMessageHandler {
    static let channelName = "webBridge"
    static let functionName = "webBridge"
    
    protocol SubHandler {
        func handler(
            _ handler: WebBridgeMessageHandler,
            didReceiveMessage message: WebBridgeMessage
        ) async throws
    }
    
    let subHandlers: [SubHandler]
    init(subHandlers: [SubHandler], webView: WKWebView? = nil) {
        self.subHandlers = subHandlers
        self.webView = webView
    }
    
    var webView: WKWebView?
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == Self.channelName
        else { return }
        
        guard let body = message.body as? String,
              let webBridgeMessage = try? WebBridgeMessage(jsonString: body)
        else {
            try? send(
                message: WebBridgeMessage(
                    messageId: WebBridgeMessage.rootMessageId,
                    payload: ErrorWebBridgePayload(error: .invalidFormat)
                )
            )
            return
        }
        
        Task {
            do {
                for subHandler in subHandlers {
                    try await subHandler.handler(
                        self,
                        didReceiveMessage: webBridgeMessage
                    )
                }
            } catch {
                try? send(
                    message: WebBridgeMessage(
                        messageId: webBridgeMessage.messageId,
                        payload: ErrorWebBridgePayload(error: .unknown)
                    )
                )
            }
        }
    }
    
    func send(message: WebBridgeMessage) throws {
        guard let webView else { return }
        
        let messageJSON = try {
            do {
                return try message.asJSON()
            } catch {
                return try WebBridgeMessage(
                    messageId: message.messageId,
                    payload: ErrorWebBridgePayload(error: .unknown)
                ).asJSON()
            }
        }().replacingOccurrences(of: "\\\"", with: "\\\\\"")
        
        let javascriptInstruction = "\(Self.functionName)('\(messageJSON)')"
        DispatchQueue.main.async {
            webView.evaluateJavaScript(javascriptInstruction)
        }
    }
}

extension WebBridgeMessageHandler.SubHandler {
    @discardableResult func wrap<TPayload: Codable>(
        handler: WebBridgeMessageHandler,
        message: WebBridgeMessage,
        _ action: (WebBridgeMessage, TPayload) async throws -> (any Codable)?
    ) async -> Bool {
        guard String(describing: TPayload.self) == message.payloadName
        else { return false }
        
        do {
            let payload = try TPayload(jsonString: message.payload)
            if let responsePayload = try await action(message, payload) {
                try? await handler.send(
                    message: WebBridgeMessage(
                        messageId: message.messageId,
                        payload: responsePayload
                    )
                )
            }
        } catch {
            try? await handler.send(
                message: WebBridgeMessage(
                    messageId: message.messageId,
                    payload: ErrorWebBridgePayload(error: .unknown)
                )
            )
        }
        
        return true
    }
}
