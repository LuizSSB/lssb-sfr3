//
//  AppViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

class AppViewModel: ViewModel {
    struct State: ViewModelState {
        var itemList: ItemListViewModel
    }
    
    var state = State(
        itemList: Container.shared.itemListViewModel()
    )
}

extension Container {
    var appViewModel: Factory<AppViewModel> {
        self { AppViewModel() }
            .singleton
    }
}
