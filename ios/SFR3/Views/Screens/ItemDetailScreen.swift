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
        let _ = print("render detail")
        Text(viewModel.state.item.name)
        Button("asd") {
            viewModel.state.item = .init(name: String(Int.random(in: 0..<100)))
        }
    }
}
