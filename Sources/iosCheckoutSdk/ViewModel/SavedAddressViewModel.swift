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
    
    @Published var dataUpdationCompleted = false
    
    @Published var itemsCount = 0
    @Published var currencySymbol = ""
    @Published var totalAmount = ""
    @Published var brandColor = ""
    @Published var transactionId = ""
    @Published var selectedAddress : SavedAddressResponse? = nil
    @Published var toShowMoreOptions = false
    
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
    
    func setSelectedAddress(address : SavedAddressResponse, proceedToAddress : Bool) {
        selectedAddress = address
        updateUserData(proceedToAddress: proceedToAddress)
    }
    
    func extractNames(from fullName: String) -> (firstName: String, lastName: String) {
        let components = fullName.split(separator: " ")
        
        guard let first = components.first else {
            return ("", "")
        }

        let last = components.dropFirst().joined(separator: " ")
        
        return (String(first), last)
    }
    
    func updateUserData(proceedToAddress : Bool) {
        Task {
            let (firstName, lastName) = extractNames(from: selectedAddress?.name ?? "")
            await userDataManager.setFirstName(firstName)
            await userDataManager.setLastName(lastName)
            await userDataManager.setPhone(selectedAddress?.phoneNumber)
            await userDataManager.setEmail(selectedAddress?.email)
            await userDataManager.setPinCode(selectedAddress?.postalCode)
            await userDataManager.setCountryCode(selectedAddress?.countryCode)
            await userDataManager.setCity(selectedAddress?.city)
            await userDataManager.setState(selectedAddress?.state)
            await userDataManager.setAddress1(selectedAddress?.address1)
            await userDataManager.setAddress2(selectedAddress?.address2)
            await userDataManager.setLabelName(selectedAddress?.labelName)
            await userDataManager.setLabelType(selectedAddress?.labelType)
            
            self.dataUpdationCompleted = proceedToAddress
        }
    }
}
