//
//  ItemListViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

@Observable class ItemListViewModel: ViewModel {
    struct State: ViewModelState {
        var items = [Item(name: "foo")]
        
        var detail: ItemDetailViewModel?
    }
    
    var state = State()
    
    func select(item: Item) {
        state.detail = .init(item: item)
    }
}

extension Container {
    var itemListViewModel: Factory<ItemListViewModel> {
        self { ItemListViewModel() }
    }
}
