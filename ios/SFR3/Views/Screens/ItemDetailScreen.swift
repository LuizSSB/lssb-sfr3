//
//  ItemDetailScreen.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import SwiftUI

struct ItemDetailScreen: View {
    @State var viewModel: ItemDetailViewModel
    
    var body: some View {
        WebViewContainer(
            content: .remote("http://localhost:5173/item/\(viewModel.state.item?.id ?? "")"),
            messageHandlers: [
                viewModel.itemFormMessageHandler,
                viewModel.navigationMessageHandler
            ]
        )
            .edgesIgnoringSafeArea(.all)
    }
}
