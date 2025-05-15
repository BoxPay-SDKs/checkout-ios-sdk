//
//  CheckoutViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import Foundation
import UIKit

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var isFirstLoad : Bool = true
    @Published var upiCollectMethod:Bool = false
    @Published var upiIntentMethod : Bool = false
    @Published var upiQrMethod : Bool = false
    @Published var cardsMethod: Bool = false
    @Published var walletsMethod : Bool = false
    @Published var netBankingMethod : Bool = false
    @Published var emiMethod: Bool = false
    @Published var bnplMethod : Bool = false
    @Published var actions : PaymentAction?
    
    let checkoutManager = CheckoutManager.shared
    let userDataManager = UserDataManager.shared
    let apiManager = ApiService.shared
    private var hasFetechedCheckoutDetails = false
    @Published var sessionData: CheckoutSession? {
        didSet {
            if let items = sessionData?.paymentDetails.order?.items {
                            let total = items.reduce(0) { sum, item in
                                sum + (item.quantity > 0 ? item.quantity : 1)
                            }
                            itemsCount = total
                checkoutManager.setItemsCount(total)
                            print("Total items count: \(itemsCount)")
                        }
            if let data = sessionData?.paymentDetails.money {
                checkoutManager.setCurrencySymbol(getCurrencySymbol(from: data.currencyCode))
                checkoutManager.setAmount(data.amountLocaleFull ?? "")
            }
            if let data = sessionData?.configs.paymentMethods {
                for paymentMethod in data {
                    if(paymentMethod.brand == "UpiQr" && !upiQrMethod) {
                        upiQrMethod = true
                    }
                    if(paymentMethod.type == "Wallet" && !walletsMethod) {
                        walletsMethod = true
                    }
                    if(paymentMethod.type == "Card" && !cardsMethod) {
                        cardsMethod = true
                    }
                    if(paymentMethod.type == "NetBanking" && !netBankingMethod) {
                        netBankingMethod = true
                    }
                    if(paymentMethod.brand == "UpiCollect" && !upiCollectMethod) {
                        upiCollectMethod = true
                    }
                    if(paymentMethod.brand == "UpiIntent" && !upiIntentMethod) {
                        upiIntentMethod = true
                    }
                    if(paymentMethod.type == "BuyNowPayLater" && !bnplMethod) {
                        bnplMethod = true
                    }
                    if(paymentMethod.type == "Emi" && !emiMethod) {
                        emiMethod = true
                    }
                }
            }
            if let userData = sessionData?.paymentDetails.shopper {
                userDataManager.setFirstName(userData.firstName)
                userDataManager.setLastName(userData.lastName)
                userDataManager.setEmail(userData.email)
                userDataManager.setPhone(userData.phoneNumber)
                userDataManager.setUniqueId(userData.uniqueReference)
                userDataManager.setAddress1(userData.deliveryAddress?.address1)
                userDataManager.setAddress2(userData.deliveryAddress?.address2)
                userDataManager.setCity(userData.deliveryAddress?.city)
                userDataManager.setState(userData.deliveryAddress?.state)
                userDataManager.setCountryCode(userData.deliveryAddress?.countryCode)
                userDataManager.setPinCode(userData.deliveryAddress?.postalCode)
                userDataManager.setLabelType(userData.deliveryAddress?.labelType)
                userDataManager.setLabelName(userData.deliveryAddress?.labelName)
                userDataManager.setDOB(userData.dateOfBirth)
                userDataManager.setPan(userData.panNumber)
            }
        }
    }
    @Published var errorReason: String = ""
    @Published var itemsCount : Int = 0

    var paymentOptionList: [PaymentMethod] {
        sessionData?.configs.paymentMethods ?? []
    }

    /// Fetches the checkout session using the main token
    func getCheckoutSession() {
        guard !hasFetechedCheckoutDetails else { return }
        apiManager.request(
                responseType: CheckoutSession.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isFirstLoad = false
                    switch result {
                    case .success(let data):
                        self?.checkoutManager.setStatus(data.status?.uppercased() ?? "")
                        self?.checkoutManager.setTransactionId(data.lastTransactionId ?? "")
                        self?.actions = CommonFunctions.handle(timeStamp: data.sessionExpiryTimestampLocale, reasonCode: "", reason: "", methodType: "", response: PaymentActionResponse(action: nil), shopperVpa: "")
                        self?.sessionData = data
                    case .failure(let error):
                        self?.actions = CommonFunctions.handle(timeStamp: "", reasonCode: "", reason: "", methodType: "", response: PaymentActionResponse(action: nil), shopperVpa: "")
                        print("=======errorr \(error)")
                    }
                }
                self?.hasFetechedCheckoutDetails = true
            }
        }
    
    func getCurrencySymbol(from currencyCode: String?) -> String {
        guard let code = currencyCode else { return "₹" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        
        // This will return the symbol for the currency, e.g., "$", "€", "₹", etc.
        return formatter.currencySymbol ?? "₹"
    }
}
