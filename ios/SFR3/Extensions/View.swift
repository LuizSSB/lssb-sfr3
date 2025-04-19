//
//  View.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    private struct WrapperView: View {
        let content: Content
        let action: () -> Void
        
        @State var appeared = false
        
        var body: some View {
            content
                .onAppear {
                    if !appeared {
                        appeared = true
                        action()
                    }
                }
        }
    }
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        WrapperView(content: content, action: action)
    }
}

extension View {
    func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }
}
