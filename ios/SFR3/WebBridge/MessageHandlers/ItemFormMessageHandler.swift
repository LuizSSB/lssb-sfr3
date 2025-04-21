//
//  ItemFormMessageHandler.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import WebKit
import Factory

struct ItemFormMessageHandler: WebBridgeMessageHandler.SubHandler {
    @Injected(\.itemDataSource) private var itemDataSource
    
    func handler(
        _ handler: WebBridgeMessageHandler,
        didReceiveMessage message: WebBridgeMessage
    ) async throws {
        if await self.wrap(
            handler: handler,
            message: message,
            {
                (m, request: GetItemRequestWebBridgePayload) in
                let item = try await itemDataSource.get(request.itemId)
                return GetItemResponseWebBridgePayload(item: item)
            }
        ) { return }
        
        if await self.wrap(
            handler: handler,
            message: message,
            {
                (m, request: CheckItemNameAvailabilityRequestWebBridgePayload) in
                let items = try await itemDataSource.list(.first())
                let itemName = request.itemName.lowercased()
                let isAvailable = items.entries.allSatisfy {
                    if $0.name.lowercased() == itemName {
                        if let itemId = request.itemId,
                           itemId == $0.id {
                            return true
                        }
                        return false
                    }
                    return true
                }
                return CheckItemNameAvailabilityResponseWebBridgePayload(
                    isAvailable: isAvailable
                )
            }
        ) { return }
        
        if await self.wrap(
            handler: handler,
            message: message,
            {
                (m, request: SaveItemRequestWebBridgePayload) in
                try await itemDataSource.upsert(request.item)
                NotificationCenter.default.post(
                    ItemSavedAppNotification(item: request.item)
                )
                return SaveItemResponseWebBridgePayload()
            }
        ) { return }
    }
}
