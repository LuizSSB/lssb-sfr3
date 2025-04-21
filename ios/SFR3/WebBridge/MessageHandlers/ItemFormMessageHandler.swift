//
//  ItemFormMessageHandler.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import WebKit
import Factory

class ItemFormMessageHandler: NSObject, WebBridgeMessageHandler {
    let channelName = "itemForm"
    
    @Injected(\.itemDataSource) private var itemDataSource
    
    var webView: WKWebView?
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == channelName, let webView
        else { return }
        
        guard let body = message.body as? String,
              let webBridgeMessage = try? WebBridgeMessage(jsonString: body)
        else {
            try? messageWebBridge(
                to: webView,
                message: WebBridgeMessage(
                    messageId: WebBridgeMessage.rootMessageId,
                    payload: ErrorWebBridgePayload(error: 0)
                )
            )
            return
        }
        
        Task {
            if await wrapWebBridgeMessageHandler(
                to: webView,
                message: webBridgeMessage,
                {
                    (m, request: GetItemRequestWebBridgePayload) in
                    let item = try await itemDataSource.get(request.itemId)
                    return GetItemResponseWebBridgePayload(item: item)
                }
            ) { return }
            
            if await wrapWebBridgeMessageHandler(
                to: webView,
                message: webBridgeMessage,
                {
                    (m, request: CheckItemNameAvailabilityRequestWebBridgePayload) in
                    let items = try await itemDataSource.list(.first())
                    return CheckItemNameAvailabilityResponseWebBridgePayload(
                        isAvailable: items.entries.allSatisfy {
                            if $0.name == request.itemName {
                                if let itemId = request.itemId,
                                   itemId == $0.id {
                                    return true
                                }
                                return false
                            }
                            return true
                        }
                    )
                }
            ) { return }
            
            if await wrapWebBridgeMessageHandler(
                to: webView,
                message: webBridgeMessage,
                {
                    (m, request: SaveItemRequestWebBridgePayload) in
                    try await itemDataSource.upsert(request.item)
                    return SaveItemResponseWebBridgePayload()
                }
            ) { return }
            
            try? messageWebBridge(
                to: webView,
                message: WebBridgeMessage(
                    messageId: WebBridgeMessage.rootMessageId,
                    payload: ErrorWebBridgePayload(error: 0)
                )
            )
        }
    }
}
