//
//  ItemDetailViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

@Observable class ItemDetailViewModel: ViewModel {
    struct State: ViewModelState {
        var item: Item?
    }
    
    var state: State
    
    @ObservationIgnored
    let itemFormMessageHandler = ItemFormMessageHandler()
    
    @ObservationIgnored
    let navigationMessageHandler = NavigationMessageHandler()
    
    init(item: Item? = nil) {
        state = .init(item: item)
    }
}

extension Container {
    var itemDetailViewModel: Factory<(Item) -> ItemDetailViewModel> {
        self { ItemDetailViewModel.init(item:) }
            .singleton
    }
}
