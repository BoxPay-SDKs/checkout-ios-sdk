//
//  DismissManager.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 30/01/25.
//


import SwiftUI

class DismissManager: ObservableObject {
    static let shared = DismissManager()
    
    private var dismissActions: [String: () -> Void] = [:]  // Store dismiss functions with screen names
    
    /// Register a dismiss action for a specific screen.
    func register(_ name: String, action: @escaping () -> Void) {
        dismissActions[name] = action
    }
    
    /// Dismiss a specific screen by name.
    func dismiss(_ name: String) {
        dismissActions[name]?() // Call the dismiss action if it exists
        dismissActions.removeValue(forKey: name) // Remove after dismissing
    }
    
    /// Dismiss all registered screens.
    func dismissAll() {
        dismissActions.values.forEach { $0() } // Call all dismiss actions
        dismissActions.removeAll() // Clear all after dismissing
    }
}

