//
//  ItemDetailViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

@Observable class DetailViewModel: ViewModel {
    struct State: ViewModelState {
        let item: Item
    }
    
    let state: State
    
    init(item: Item) {
        state = .init(item: item)
    }
}

extension Container {
    var detailViewModel: Factory<(Item) -> DetailViewModel> {
        self { DetailViewModel.init(item:) }
            .singleton
    }
}
