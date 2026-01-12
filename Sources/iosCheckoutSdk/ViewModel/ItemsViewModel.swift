//
//  ItemsViewModel.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 23/07/25.
//

import SwiftUI

@MainActor
class ItemsViewModel : ObservableObject {
    private let checkoutManager = CheckoutManager.shared
    private let userDataManager = UserDataManager.shared
    
    @Published var brandColor = ""
    @Published var amount = ""
    @Published var currencySymbol = ""
    
    @Published var selectedInstrumentValue = ""
    @Published var selectedDisplayName = ""
    @Published var selectedPaymentType = ""
    @Published var selectedSource = ""
    
    init() {
        Task {
            brandColor = await checkoutManager.getBrandColor()
            amount = await checkoutManager.getTotalAmount()
            currencySymbol = await checkoutManager.getCurrencySymbol()
        }
    }
    
    
    func onChangeInstrumentValue(newInstrumentValue : String, newDisplayValue : String, paymentType : String, source : String) {
        selectedInstrumentValue = newInstrumentValue
        selectedDisplayName = newDisplayValue
        selectedPaymentType = paymentType
        selectedSource = source
    }
}
