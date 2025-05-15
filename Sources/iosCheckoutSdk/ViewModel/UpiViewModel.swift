//
//  UpiViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import UIKit

@MainActor
class UpiViewModel : ObservableObject {
    @Published var isLoading: Bool = false
    @Published var paymentUrl : String? = nil
    @Published var status: String = "NOACTION"
    @Published var transactionId : String = ""
    @Published var errorReason: String = ""
    @Published var actions : PaymentAction?
    
    
    let checkoutManager = CheckoutManager.shared
    let userDataManager = UserDataManager.shared
    let apiManager = ApiService.shared
    
    func initiateUpiPostRequest(_ selectedIntent : String? , _ shopperVpa : String?, methodType:String) {
        // Construct instrumentDetails
        self.isLoading = true
            var instrumentDetails: [String: Any] = [
                "type": selectedIntent != nil ? "upi/intent" : "upi/collect"
            ]

            if let intent = selectedIntent {
                instrumentDetails["upiAppDetails"] = ["upiApp": intent]
            } else if let vpa = shopperVpa {
                instrumentDetails["upi"] = ["shopperVpa": vpa]
            }

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

        
        apiManager.request(
            method : .POST,
            headers: [
                "Content-Type": "application/json",
                "X-REQUEST-ID": CommonFunctions.generateRandomAlphanumericString(length: 10)
            ],
            body: jsonData,
            responseType: GeneralPaymentInitilizationResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let data):
                        self?.checkoutManager.setStatus(data.status.status.uppercased())
                        self?.checkoutManager.setTransactionId(data.transactionId)
                        self?.actions = CommonFunctions.handle(timeStamp: data.transactionTimestampLocale, reasonCode: data.status.reasonCode, reason: data.status.reason, methodType: methodType, response: PaymentActionResponse(action: data.actions), shopperVpa: shopperVpa ?? "")
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
