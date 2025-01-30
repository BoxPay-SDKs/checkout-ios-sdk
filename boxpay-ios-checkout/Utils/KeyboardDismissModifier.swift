//
//  KeyboardDismissModifier.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 28/01/25.
//


import SwiftUI

extension View {
    /// Dismiss the keyboard when tapped or swiped outside a TextField or when using ScrollView
    func hideKeyboardOnTap() -> some View {
        self
            .modifier(KeyboardDismissModifier())
    }
}

private struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle()) // Making the background tappable
                    .gesture(
                        // When tapped or swiped, dismiss the keyboard
                        TapGesture().onEnded {
                            dismissKeyboard()
                        }
                    )
            )
    }

    /// Dismiss the keyboard using the SwiftUI-native method
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


