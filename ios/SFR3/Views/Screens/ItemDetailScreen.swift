//
//  ItemDetailScreen.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import SwiftUI

struct ItemDetailScreen: View {
    @Environment(\.dismiss) var dismiss
    
    @State var viewModel: ItemDetailViewModel
    
    var body: some View {
        WebViewContainer(
            content: WebContentReference.forWebComponent,
            path: viewModel.state.route.path,
            messageHandlers: [
                viewModel.itemFormMessageHandler,
                viewModel.navigationMessageHandler
            ]
        )
            .edgesIgnoringSafeArea(.all)
            .onReceive(viewModel.navigationMessageHandler.triggerCancel) {
                _ in
                dismiss()
            }
    }
}
