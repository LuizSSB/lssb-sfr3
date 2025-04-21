//
//  ItemList.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

struct ItemListScreen: View {
    @State var viewModel: ItemListViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.state.items ?? [], id: \.name) { item in
                Button(item.name) {
                    viewModel.select(item: item)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.add()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.refresh()
        }
        .navigationDestination(item: $viewModel.state.detail) { detail in
            ItemDetailScreen(viewModel: detail)
        }
    }
}
