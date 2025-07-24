//
//  WalletViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import UIKit

@MainActor
class WalletViewModel : ObservableObject {

    @Published var isFirstLoad = true
    @Published var isLoading = false
    @Published var actions : PaymentAction?
    @Published var checkoutManager = CheckoutManager.shared
    private let apiService = ApiService.shared
    private let userDataManager = UserDataManager.shared
    
    @Published var walletDataClass : [CommonDataClass] = []
    @Published var defaultWalletDataClass : [CommonDataClass] = []
    
    @Published var itemsCount = 0
    @Published var currencySymbol = ""
    @Published var totalAmount = ""
    @Published var brandColor = ""
    @Published var transactionId = ""
    
    func getWalletPaymentMethods() {
        Task {
            do {
                let data = try await apiService.request(
                    endpoint: "payment-methods",
                    responseType: [PaymentMethod].self
                )

                let filteredData = data.filter { $0.type == "Wallet" }.map { item in
                    CommonDataClass(
                        type: "Wallet",
                        id: item.id ?? "",
                        displayName: item.title ?? "",
                        displayNumber: "",
                        logoUrl: item.logoUrl ?? "",
                        instrumentTypeValue: item.instrumentTypeValue ?? ""
                    )
                }

                self.walletDataClass = filteredData
                self.defaultWalletDataClass = filteredData
                self.itemsCount = await checkoutManager.getItemsCount()
                self.currencySymbol = await checkoutManager.getCurrencySymbol()
                self.totalAmount = await checkoutManager.getTotalAmount()
                self.brandColor = await checkoutManager.getBrandColor()
                self.isFirstLoad = false
            } catch {
                self.isFirstLoad = false
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: "",
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
        }
    }

    func initiateWalletPostRequest(instrumentValue: String) {
        Task {
            await MainActor.run { self.isLoading = true }

            let instrumentDetails: [String: Any] = [
                "type": instrumentValue,
                "wallet": [
                    "token": await checkoutManager.getMainToken()
                ]
            ]

            let deliveryAddress: [String: Any?] = await [
                "address1": userDataManager.getAddress1(),
                "address2": userDataManager.getAddress2(),
                "city": userDataManager.getCity(),
                "state": userDataManager.getState(),
                "countryCode": userDataManager.getCountryCode(),
                "postalCode": userDataManager.getPinCode(),
                "labelType": userDataManager.getLabelType(),
                "labelName": userDataManager.getLabelName()
            ]

            let isDeliveryEmpty = deliveryAddress.values.contains { value in
                if value == nil {
                    return true
                }
                if let str = value as? String {
                    return str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                return false // Non-string & non-nil values considered valid
            }
            let payload: [String: Any] = await [
                "browserData": [
                    "screenHeight": Int(UIScreen.main.bounds.height),
                    "screenWidth": Int(UIScreen.main.bounds.width),
                    "acceptHeader": "application/json",
                    "userAgentHeader": "iOS App",
                    "browserLanguage": Locale.current.identifier,
                    "ipAddress": "null",
                    "colorDepth": 24,
                    "javaEnabled": true,
                    "timeZoneOffSet": TimeZone.current.secondsFromGMT() / 60,
                    "packageId": Bundle.main.bundleIdentifier ?? "com.boxpay.checkout.sdk"
                ],
                "instrumentDetails": instrumentDetails,
                "shopper": [
                    "email": userDataManager.getEmail(),
                    "firstName": userDataManager.getFirstName(),
                    "lastName": userDataManager.getLastName(),
                    "phoneNumber": userDataManager.getPhone(),
                    "uniqueReference": userDataManager.getUniqueId(),
                    "dateOfBirth": userDataManager.getDOB(),
                    "panNumber": userDataManager.getPan(),
                    "deliveryAddress": isDeliveryEmpty ? nil : deliveryAddress
                ],
                "deviceDetails": [
                    "browser": "iOS",
                    "platformVersion": UIDevice.current.systemVersion,
                    "deviceType": UIDevice.current.model,
                    "deviceName": UIDevice.current.name,
                    "deviceBrandName": "Apple"
                ]
            ]

            guard JSONSerialization.isValidJSONObject(payload),
                  let jsonData = try? JSONSerialization.data(withJSONObject: payload),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                return
            }
            do {
                let data = try await apiService.request(
                    method: .POST,
                    headers: StringUtils.getRequestHeaders(),
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )

                await checkoutManager.setStatus(data.status.status.uppercased())
                await checkoutManager.setTransactionId(data.transactionId)
                self.transactionId = data.transactionId

                self.actions = await PaymentActionUtils.handle(
                    timeStamp: data.transactionTimestampLocale,
                    reasonCode: data.status.reasonCode,
                    reason: data.status.reason,
                    methodType: "WALLET",
                    response: PaymentActionResponse(action: data.actions),
                    shopperVpa: ""
                )

            } catch {
                let errorDescription = error.localizedDescription.lowercased()

                if errorDescription.contains("expired") {
                    await checkoutManager.setStatus("EXPIRED")
                } else {
                    await checkoutManager.setStatus("FAILED")
                }

                self.actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }

            await MainActor.run { self.isLoading = false }
        }
    }
}
