//
//  WebBridgeUtils.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import WebKit

protocol WebBridgeMessageHandler: WKScriptMessageHandler {
    var channelName: String { get }
    var webView: WKWebView? { get set }
}

fileprivate let webBridgeMessageFunctionName = "webBridge"

func messageWebBridge(to webView: WKWebView, message: WebBridgeMessage) throws {
    let messageJSON = try {
        do {
            return try message.asJSON()
        } catch {
            return try WebBridgeMessage(
                messageId: message.messageId,
                payload: ErrorWebBridgePayload(error: 0)
            ).asJSON()
        }
    }()
    let javascriptInstruction = "\(webBridgeMessageFunctionName)('\(messageJSON)')"
    DispatchQueue.main.async {
        webView.evaluateJavaScript(javascriptInstruction)
    }
}


func wrapWebBridgeMessageHandler<TPayload: Codable>(
    to: WKWebView,
    message: WebBridgeMessage,
    _ action: (WebBridgeMessage, TPayload) async throws -> (any Codable)?
) async -> Bool {
    guard String(describing: TPayload.self) == message.payloadName
    else { return false }
    
    do {
        let payload = try TPayload(jsonString: message.payload)
        if let responsePayload = try await action(message, payload) {
            try? messageWebBridge(
                to: to,
                message: WebBridgeMessage(
                    messageId: message.messageId,
                    payload: responsePayload
                )
            )
        }
    } catch {
        try? messageWebBridge(
            to: to,
            message: WebBridgeMessage(
                messageId: message.messageId,
                payload: ErrorWebBridgePayload(error: 0)
            )
        )
    }
    
    return true
}
