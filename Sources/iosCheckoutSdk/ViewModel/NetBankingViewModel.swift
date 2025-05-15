//
//  NetBankingViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import UIKit

@MainActor
class NetBankingViewModel : ObservableObject {

    @Published var isFirstLoad = true
    @Published var isLoading = false
    @Published var actions : PaymentAction?
    @Published var checkoutManager = CheckoutManager.shared
    @Published var apiService = ApiService.shared
    @Published var userDataManager = UserDataManager.shared
    
    @Published var netBankingDataClass : [CommonDataClass] = []
    @Published var defaultNetBankingDataClass : [CommonDataClass] = []
    private var popularBanksList : [String] = [
        "HDFC Bank","ICICI Bank","State Bank of India","Axis Bank","Punjab National Bank Retail"
    ]
    @Published var popularBankDataClass : [CommonDataClass] = []
    
    func getNetBankingPaymentMethods() {
        apiService.request(
            endpoint: "payment-methods",
            responseType: [PaymentMethod].self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isFirstLoad = false
                    switch result {
                    case .success(let data):
                        self.netBankingDataClass = data
                            .filter { $0.type == "NetBanking" }
                            .map { item in
                                CommonDataClass(
                                    id: item.id ?? "",
                                    title: item.title ?? "",
                                    image: item.logoUrl ?? "",
                                    instrumentTypeValue: item.instrumentTypeValue ?? "",
                                    isLastUsed: nil
                                )
                            }
                        
                        self.defaultNetBankingDataClass = self.netBankingDataClass
                        
                        self.popularBankDataClass = self.netBankingDataClass.filter { bank in
                            self.popularBanksList.contains { popularName in
                                bank.title.caseInsensitiveCompare(popularName) == .orderedSame
                            }
                        }

                    case .failure(let error):
                        self.actions = CommonFunctions.handle(timeStamp: "", reasonCode: "", reason: "", methodType: "", response: PaymentActionResponse(action: nil), shopperVpa: "")
                        print("=======errorr \(error)")
                    }
                }

            }
    }
    
    func initiateNetBankingPostRequest(instrumentValue:String) {
        // Construct instrumentDetails
        self.isLoading = true
            let instrumentDetails: [String: Any] = [
                "type": instrumentValue,
                "netBanking" : [
                    "token" : checkoutManager.getMainToken()
                ]
            ]

            // Construct delivery address
            let deliveryAddress: [String: Any?] = [
                "address1": userDataManager.getAddress1(),
                "address2": userDataManager.getAddress2(),
                "city": userDataManager.getCity(),
                "state": userDataManager.getState(),
                "countryCode": userDataManager.getCountryCode(),
                "postalCode": userDataManager.getPinCode(),
                "labelType": userDataManager.getLabelType(),
                "labelName": userDataManager.getLabelName()
            ]

            let isDeliveryEmpty = deliveryAddress.values.allSatisfy { value in
                (value as? String)?.isEmpty ?? true
            }
        

            let payload: [String: Any] = [
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
        
        guard JSONSerialization.isValidJSONObject(payload) else {
            print("❌ Invalid JSON")
            return
        }

        let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: [])
        
        if let json = jsonData, let jsonString = String(data: json, encoding: .utf8) {
            print("📤 JSON Payload:\n\(jsonString)")
        }

        
        apiService.request(
            method : .POST,
            headers: [
                "Content-Type": "application/json",
                "X-REQUEST-ID": CommonFunctions.generateRandomAlphanumericString(length: 10)
            ],
            body: jsonData,
            responseType: GeneralPaymentInitilizationResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self?.checkoutManager.setStatus(data.status.status.uppercased())
                        self?.checkoutManager.setTransactionId(data.transactionId)
                        self?.actions = CommonFunctions.handle(timeStamp: data.transactionTimestampLocale, reasonCode: data.status.reasonCode, reason: data.status.reason, methodType: "WALLET", response: PaymentActionResponse(action: data.actions), shopperVpa:"")
                    case .failure(let error):
                        let errorDescription = error.localizedDescription.lowercased()

                        if errorDescription.contains("expired") {
                            self?.checkoutManager.setStatus("EXPIRED")
                        } else {
                            self?.checkoutManager.setStatus("FAILED")
                        }

                        self?.actions = CommonFunctions.handle(
                            timeStamp: "",
                            reasonCode: "",
                            reason: error.localizedDescription, // You can pass actual error for better debugging
                            methodType: "",
                            response: PaymentActionResponse(action: nil),
                            shopperVpa: ""
                        )

                        print("=======errorr \(error)")
                    }
                }
            }
    }
}
