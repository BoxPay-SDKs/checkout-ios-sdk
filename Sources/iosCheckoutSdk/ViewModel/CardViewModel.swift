//
//  CardViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import Foundation
import UIKit

@MainActor
class CardViewModel: ObservableObject {
    @Published var actions: PaymentAction?
    @Published var isLoading : Bool = false
    @Published var checkoutManager = CheckoutManager.shared
    private let apiManager = ApiService.shared
    @Published var cardResponse : CardInfoResponse?
    let userDataManager = UserDataManager.shared

    
    func fetchCardInfo(_ cardNumber:String) {
        apiManager.request(
            endpoint: "bank-identification-numbers/\(cardNumber)",
            method: .POST,
            headers: [
                "Content-Type": "application/json",
                "X-REQUEST-ID": CommonFunctions.generateRandomAlphanumericString(length: 10)
            ],
            responseType: CardInfoResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("==========data: \(data)")
                    self?.cardResponse = data
                case .failure(let error):
                    print("=======error: \(error)")
                }
            }
        }
    }
    
    func initiateCardPostRequest(cardNumber:String, cardExpiry:String, cardCvv:String, cardHolderName:String) {
        // Construct instrumentDetails
        self.isLoading = true
        var expiry = formatExpiry(cardExpiry)
            var instrumentDetails: [String: Any] = [
                "type": "card/plain",
                "card" : [
                    "number" : cardNumber,
                    "expiry": expiry,
                    "cvc": cardCvv,
                    "holderName": cardHolderName
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
                        self?.actions = CommonFunctions.handle(timeStamp: data.transactionTimestampLocale, reasonCode: data.status.reasonCode, reason: data.status.reason, methodType: "CARD", response: PaymentActionResponse(action: data.actions), shopperVpa:"")
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
    
    func formatExpiry(_ input: String) -> String {
        let components = input.split(separator: "/")
        guard components.count == 2,
              let month = components.first,
              let year = components.last else {
            return input // or return "" if you prefer a default on invalid input
        }
        
        return "20\(year)-\(month)"
    }

    
    func initiateEMICardPostRequest(cardNumber:String, cardExpiry:String, cardCvv:String, cardHolderName:String, cardType:String, offerCode:String?, duration:String) {
        // Construct instrumentDetails
        self.isLoading = true
        let instrumentType = cardType.contains("Credit") == true ? "emi/cc" :  "emi/dc"
        var expiry = formatExpiry(cardExpiry)
            var instrumentDetails: [String: Any] = [
                "type": instrumentType,
                "card" : [
                    "number" : cardNumber,
                    "expiry": expiry,
                    "cvc": cardCvv,
                    "holderName": cardHolderName
                ],
                "emi" : [
                    "duration" : duration
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
        

        var payload: [String: Any] = [
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
        
        if ((offerCode?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) != nil) {
            payload["offers"] = [offerCode]
        }
        
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
                        self?.actions = CommonFunctions.handle(timeStamp: data.transactionTimestampLocale, reasonCode: data.status.reasonCode, reason: data.status.reason, methodType: "CARD", response: PaymentActionResponse(action: data.actions), shopperVpa:"")
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
