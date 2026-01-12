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
    @Published var shopperToken = ""
    
    @Published var transactionId = ""

    
    init() {
        Task {
            shopperToken = await checkoutManager.getShopperToken()
        }
    }
    
    
    func fetchCardInfo(_ cardNumber: String) {
        Task {
            do {
                let data: CardInfoResponse = try await apiService.request(
                    endpoint: "bank-identification-numbers/\(cardNumber)",
                    method: .POST,
                    responseType: CardInfoResponse.self
                )
                self.cardResponse = data
            } catch {
            }
        }
    }
    
    func initiateCardPostRequest(cardNumber: String, cardExpiry: String, cardCvv: String, cardHolderName: String, isSavedCardCheckBoxClicked : Bool, cardNickName : String) {
        Task {
            self.isLoading = true
            
            print(cardCvv)
            
            let expiry = formatExpiry(cardExpiry)
            
            var instrumentDetails: [String: Any] = [
                "type": "card/plain",
                "card": [
                    "number": cardNumber,
                    "expiry": expiry,
                    "cvc": cardCvv,
                    "holderName": cardHolderName,
                    "nickName" : !shopperToken.isEmpty && !cardNickName.isEmpty ? cardNickName : nil
                ]
            ]
            
            var headers = StringUtils.getRequestHeaders()

            if !shopperToken.isEmpty {
                headers["Authorization"] = "Session \(shopperToken)"
                instrumentDetails["saveInstrument"] = isSavedCardCheckBoxClicked
            }
            
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
            
            let isDeliveryEmpty = deliveryAddress.values.contains { value in
                if value == nil {
                    return true
                }
                if let str = value as? String {
                    return str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                return false // Non-string & non-nil values considered valid
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
                    headers: headers,
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                
                await self.checkoutManager.setStatus(data.status.status.uppercased())
                await self.checkoutManager.setTransactionId(data.transactionId)
                transactionId = data.transactionId
                self.actions = await PaymentActionUtils.handle(
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
                
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
        }
    }
    
    func initiateEMICardPostRequest(cardNumber: String, cardExpiry: String, cardCvv: String, cardHolderName: String, cardType: String, offerCode: String?, duration: String, isSavedCardCheckBoxClicked : Bool, cardNickName : String) {
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
                    "holderName": cardHolderName,
                    "nickName" : !shopperToken.isEmpty && !cardNickName.isEmpty ? cardNickName : nil
                ],
                "emi": [
                    "duration": duration
                ]
            ]
            
            var headers = StringUtils.getRequestHeaders()

            if !shopperToken.isEmpty {
                headers["Authorization"] = "Session \(shopperToken)"
                instrumentDetails["saveInstrument"] = isSavedCardCheckBoxClicked
            }
            
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
            
            let isDeliveryEmpty = deliveryAddress.values.contains { value in
                if value == nil {
                    return true
                }
                if let str = value as? String {
                    return str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                return false // Non-string & non-nil values considered valid
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
                    headers: headers,
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                
                await self.checkoutManager.setStatus(data.status.status.uppercased())
                await self.checkoutManager.setTransactionId(data.transactionId)
                self.actions = await PaymentActionUtils.handle(
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
                
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
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
