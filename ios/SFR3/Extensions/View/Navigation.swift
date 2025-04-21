//
//  Navigation.swift
//  SFR3
//
//  Created by Luiz SSB on 21/04/25.
//

import SwiftUI

extension View {
    func viewModelFullScreenCover<TViewModel: ViewModel>(
        _ viewModel: Binding<TViewModel?>,
        @ViewBuilder destination: @escaping (TViewModel) -> any View
    ) -> some View {
        return self
            .fullScreenCover(
                isPresented: .init(
                    get: { viewModel.wrappedValue != nil },
                    set: { _ in viewModel.wrappedValue = nil }
                )
            ) {
                if let viewModel = viewModel.wrappedValue {
                    AnyView(destination(viewModel))
                }
            }
    }
}
