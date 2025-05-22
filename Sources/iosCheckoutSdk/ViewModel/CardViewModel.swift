import Foundation
import UIKit

@MainActor
class CardViewModel: ObservableObject {
    @Published var actions: PaymentAction?
    @Published var isLoading : Bool = false
    @Published var checkoutManager = CheckoutManager.shared
    private let apiService = ApiService.shared
    @Published var cardResponse : CardInfoResponse?
    let userDataManager = UserDataManager.shared
    
    @Published var transactionId = ""

    func fetchCardInfo(_ cardNumber: String) {
        Task {
            do {
                let data: CardInfoResponse = try await apiService.request(
                    endpoint: "bank-identification-numbers/\(cardNumber)",
                    method: .POST,
                    headers: [
                        "Content-Type": "application/json",
                        "X-REQUEST-ID": GlobalUtils.generateRandomAlphanumericString(length: 10)
                    ],
                    responseType: CardInfoResponse.self
                )
                self.cardResponse = data
            } catch {
            }
        }
    }
    
    func initiateCardPostRequest(cardNumber: String, cardExpiry: String, cardCvv: String, cardHolderName: String) {
        Task {
            self.isLoading = true
            
            let expiry = formatExpiry(cardExpiry)
            var instrumentDetails: [String: Any] = [
                "type": "card/plain",
                "card": [
                    "number": cardNumber,
                    "expiry": expiry,
                    "cvc": cardCvv,
                    "holderName": cardHolderName
                ]
            ]
            
            let deliveryAddress: [String: Any?] = await[
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
            
            let payload: [String: Any] = await[
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
                self.isLoading = false
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let data = try await apiService.request(
                    method: .POST,
                    headers: [
                        "Content-Type": "application/json",
                        "X-REQUEST-ID": GlobalUtils.generateRandomAlphanumericString(length: 10)
                    ],
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                
                await self.checkoutManager.setStatus(data.status.status.uppercased())
                await self.checkoutManager.setTransactionId(data.transactionId)
                transactionId = data.transactionId
                self.actions = await GlobalUtils.handle(
                    timeStamp: data.transactionTimestampLocale,
                    reasonCode: data.status.reasonCode,
                    reason: data.status.reason,
                    methodType: "CARD",
                    response: PaymentActionResponse(action: data.actions),
                    shopperVpa: ""
                )
            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                
                if errorDescription.contains("expired") {
                    await self.checkoutManager.setStatus("EXPIRED")
                } else {
                    await self.checkoutManager.setStatus("FAILED")
                }
                
                self.actions = await GlobalUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
            self.isLoading = false
        }
    }
    
    func initiateEMICardPostRequest(cardNumber: String, cardExpiry: String, cardCvv: String, cardHolderName: String, cardType: String, offerCode: String?, duration: String) {
        Task {
            self.isLoading = true
            
            let instrumentType = cardType.contains("Credit") ? "emi/cc" : "emi/dc"
            let expiry = formatExpiry(cardExpiry)
            var instrumentDetails: [String: Any] = [
                "type": instrumentType,
                "card": [
                    "number": cardNumber,
                    "expiry": expiry,
                    "cvc": cardCvv,
                    "holderName": cardHolderName
                ],
                "emi": [
                    "duration": duration
                ]
            ]
            
            let deliveryAddress: [String: Any?] = await[
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
            
            var payload: [String: Any] = await[
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
            
            if let offer = offerCode?.trimmingCharacters(in: .whitespacesAndNewlines), !offer.isEmpty {
                payload["offers"] = [offer]
            }
            
            guard JSONSerialization.isValidJSONObject(payload) else {
                self.isLoading = false
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let data = try await apiService.request(
                    method: .POST,
                    headers: [
                        "Content-Type": "application/json",
                        "X-REQUEST-ID": GlobalUtils.generateRandomAlphanumericString(length: 10)
                    ],
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                
                await self.checkoutManager.setStatus(data.status.status.uppercased())
                await self.checkoutManager.setTransactionId(data.transactionId)
                self.actions = await GlobalUtils.handle(
                    timeStamp: data.transactionTimestampLocale,
                    reasonCode: data.status.reasonCode,
                    reason: data.status.reason,
                    methodType: "CARD",
                    response: PaymentActionResponse(action: data.actions),
                    shopperVpa: ""
                )
            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                
                if errorDescription.contains("expired") {
                    await self.checkoutManager.setStatus("EXPIRED")
                } else {
                    await self.checkoutManager.setStatus("FAILED")
                }
                
                self.actions = await GlobalUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
            self.isLoading = false
        }
    }
    
    func formatExpiry(_ input: String) -> String {
        let components = input.split(separator: "/")
        guard components.count == 2,
              let month = components.first,
              let year = components.last else {
            return input
        }
        
        return "20\(year)-\(month)"
    }
}
