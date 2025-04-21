//
//  NavigationMessageHandler.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import Foundation
import WebKit
import Combine

class NavigationMessageHandler: WebBridgeMessageHandler.SubHandler {
    let triggerCancel = PassthroughSubject<Void, Never>()
    
    func handler(
        _ handler: WebBridgeMessageHandler,
        didReceiveMessage message: WebBridgeMessage
    ) async throws {
        await self.wrap(
            handler: handler,
            message: message,
        ) { (m, p: CancelWebBridgePayload) in
            let triggerCancel: @Sendable @MainActor () -> Void = { [weak self] in
                self?.triggerCancel.send()
            }
            await triggerCancel()
            return nil
        }
    }
}
