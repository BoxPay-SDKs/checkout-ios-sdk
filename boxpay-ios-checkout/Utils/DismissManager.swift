//
//  DismissManager.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 30/01/25.
//


import SwiftUI

class DismissManager: ObservableObject {
    static let shared = DismissManager()
    var dismissAction: (() -> Void)?  // Store dismiss function
    
    func dismiss() {
        dismissAction?()  // Call dismiss if available
    }
}
