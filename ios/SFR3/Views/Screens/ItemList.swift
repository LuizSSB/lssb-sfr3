//
//  ItemList.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI

struct ItemList: View {
    @State var viewModel: ItemListViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.state.items, id: \.name) { item in
                Button(item.name) { viewModel.select(item: item) }
            }
        }
        .navigationDestination(item: $viewModel.state.detail) { vm in
            Text(vm.state.item.name)
        }
    }
}
