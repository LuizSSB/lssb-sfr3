//
//  SFR3App.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

@main
struct SFR3App: App {
    @State var viewModel = Container.shared.appViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ItemListScreen(viewModel: viewModel.state.itemList)
            }
        }
    }
}
