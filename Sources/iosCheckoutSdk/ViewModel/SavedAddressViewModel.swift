//
//  SavedAddressViewModel.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 11/08/25.
//
import UIKit

@MainActor
class SavedAddressViewModel : ObservableObject {
    @Published var isFirstLoad = true
    @Published var isLoading = false
    
    @Published var checkoutManager = CheckoutManager.shared
    private let userDataManager = UserDataManager.shared
    private let apiService = ApiService.shared
    
    @Published var savedAddressList : [SavedAddressResponse] = []
    
    @Published var itemsCount = 0
    @Published var currencySymbol = ""
    @Published var totalAmount = ""
    @Published var brandColor = ""
    @Published var transactionId = ""
    @Published var selectedAddressRef = ""
    
    func getSavedAddress() {
        Task {
            do {
                let shopperToken = await checkoutManager.getShopperToken()
                let uniqueRef = await userDataManager.getUniqueId() ?? ""
                let data = try await apiService.request(
                    endpoint: "shoppers/\(uniqueRef)/addresses",
                    method: .GET,
                    headers: [
                        "Authorization" : "Session \(shopperToken)"
                    ],
                    responseType: [SavedAddressResponse].self
                )
                self.savedAddressList = data
                print(data)

                self.itemsCount = await checkoutManager.getItemsCount()
                self.currencySymbol = await checkoutManager.getCurrencySymbol()
                self.totalAmount = await checkoutManager.getTotalAmount()
                self.brandColor = await checkoutManager.getBrandColor()
                self.isFirstLoad = false
            } catch {
                self.isFirstLoad = false
            }
        }
    }
    
    func setSelectedAddressRef(addressRef : String) {
        selectedAddressRef = addressRef
    }
}
