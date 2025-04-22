//
//  ViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import Foundation
import SwiftUI

protocol ViewModelState: Equatable, Hashable {
}

protocol ViewModel: Equatable, Hashable {
    associatedtype State: ViewModelState
    var state: State { get }
}

extension ViewModel {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
}

extension ViewModel {
    func update(
        animation: Animation? = .default,
        action: @escaping () -> Void
    ) -> Void {
        DispatchQueue.main.async {
            if let animation {
                withAnimation(animation, action)
            } else {
                action()
            }
        }
    }
}
