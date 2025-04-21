//
//  WebBridgePayload.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

struct WebBridgeMessage: Codable {
    static let rootMessageId = "root"
    
    let messageId: String
    let payloadName: String
    let payload: String
}

extension WebBridgeMessage {
    init(messageId: String, payload: any Encodable) throws {
        self.messageId = messageId
        self.payloadName = String(describing: type(of: payload))
        self.payload = try payload.asJSON()
    }
}

protocol NullWebBridgePayload: Codable {
    var messageId: String { get }
}

struct ErrorWebBridgePayload: Codable {
    let error: Int
}

struct GetItemRequestWebBridgePayload: Codable {
    let itemId: String
}

struct GetItemResponseWebBridgePayload: Codable {
    let item: Item?
}

struct CheckItemNameAvailabilityRequestWebBridgePayload: Codable {
    let itemId: String?
    let itemName: String
}

struct CheckItemNameAvailabilityResponseWebBridgePayload: Codable {
    let isAvailable: Bool
}

struct SaveItemRequestWebBridgePayload: Codable {
    let item: Item
}

struct SaveItemResponseWebBridgePayload: Codable {
}
