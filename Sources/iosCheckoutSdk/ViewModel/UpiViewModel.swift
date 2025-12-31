import Foundation
import UIKit
import Combine

@MainActor
class UpiViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var paymentUrl: String? = nil
    @Published var status: String = "NOACTION"
    @Published var transactionId: String = ""
    @Published var errorReason: String = ""
    @Published var actions: PaymentAction?
    @Published var qrUrl : String = ""
    
    @Published var upiCollectVisible = false
    @Published var upiQRVisible = false
    @Published var isQRChevronRotated = false
    @Published var isCollectChevronRotated = false
    @Published var isFocused = false
    @Published var selectedIntent: String? = nil
    @Published var qrIsExpired = false

    let checkoutManager = CheckoutManager.shared
    let userDataManager = UserDataManager.shared
    let apiManager = ApiService.shared
    
    @Published var brandColor = ""
    @Published var currencySymbol = ""
    @Published var amount = ""
    
    init() {
        Task {
            brandColor = await checkoutManager.getBrandColor()
            amount = await checkoutManager.getTotalAmount()
            currencySymbol = await checkoutManager.getCurrencySymbol()
        }
    }

    func initiateUpiPostRequest(_ selectedIntent: String?, _ shopperVpa: String?, _ selectedInstrumentRef : String?, _ selectedIntrumentRefType : String?) {
        self.isLoading = true
        Task {
            let type = if selectedIntent != nil {
                "upi/intent"
            } else if let instrumentRefType = selectedIntrumentRefType, instrumentRefType == "card" {
                "card/token"
            } else {
                "upi/collect"
            }
            
            var instrumentDetails: [String: Any] = [
                "type": type
            ]

            if let intent = selectedIntent {
                instrumentDetails["upiAppDetails"] = ["upiApp": intent]
            } else if let instrumentRef = selectedInstrumentRef {
                if let type = selectedIntrumentRefType {
                    if(type == "upi") {
                        instrumentDetails["upi"] = ["instrumentRef": instrumentRef]
                    } else {
                        instrumentDetails["savedCard"] = ["instrumentRef": instrumentRef]
                    }
                }
            } else if let vpa = shopperVpa {
                instrumentDetails["upi"] = ["shopperVpa": vpa]
            }
            
            var headers = StringUtils.getRequestHeaders()

            let shopperToken = await checkoutManager.getShopperToken()
            if !shopperToken.isEmpty {
                headers["Authorization"] = "Session \(shopperToken)"
                instrumentDetails["saveInstrument"] = true
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

            guard JSONSerialization.isValidJSONObject(payload),
                  let jsonData = try? JSONSerialization.data(withJSONObject: payload),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                return
            }

            do {
                let response: GeneralPaymentInitilizationResponse = try await apiManager.request(
                    method: .POST,
                    headers: headers,
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                await self.checkoutManager.setStatus(response.status.status.uppercased())
                await self.checkoutManager.setTransactionId(response.transactionId)
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: response.transactionTimestampLocale,
                    reasonCode: response.status.reasonCode,
                    reason: response.status.reason,
                    methodType: selectedIntrumentRefType != nil && selectedIntrumentRefType == "upi" ? "UPICollect" : selectedIntent != nil ? "UpiIntent" : "",
                    response: PaymentActionResponse(action: response.actions),
                    shopperVpa: shopperVpa ?? ""
                )

            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                if errorDescription.contains("expired") {
                    await self.checkoutManager.setStatus("EXPIRED")
                } else {
                    await self.checkoutManager.setStatus("FAILED")
                }
                AnalyticsViewModel().callUIAnalytics(AnalyticsEvents.ERROR_GETTING_UPI_URL.rawValue, "UPIScreen", errorDescription)
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
    
    func initiateUpiQRPostRequest() {
        self.isLoading = true
        Task {
            var headers = StringUtils.getRequestHeaders()

            let shopperToken = await checkoutManager.getShopperToken()
            if !shopperToken.isEmpty {
                headers["Authorization"] = "Session \(shopperToken)"
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
                "instrumentDetails": [
                    "type" : "upi/qr"
                ],
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
                let response: GeneralPaymentInitilizationResponse = try await apiManager.request(
                    method: .POST,
                    headers: headers,
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                await self.checkoutManager.setStatus(response.status.status.uppercased())
                await self.checkoutManager.setTransactionId(response.transactionId)
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: response.transactionTimestampLocale,
                    reasonCode: response.status.reasonCode,
                    reason: response.status.reason,
                    methodType: "UPIQR",
                    response: PaymentActionResponse(action: response.actions),
                    shopperVpa: ""
                )

            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                if errorDescription.contains("expired") {
                    await self.checkoutManager.setStatus("EXPIRED")
                } else {
                    await self.checkoutManager.setStatus("FAILED")
                }
                AnalyticsViewModel().callUIAnalytics(AnalyticsEvents.ERROR_GETTING_UPI_URL.rawValue, "UPIScreen", errorDescription)
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
    func toggleCollectSection() {
        selectedIntent = nil
        upiCollectVisible.toggle()
        upiQRVisible = false
        isQRChevronRotated = false
        isCollectChevronRotated.toggle()
    }
    
    func toggleQRSection() {
        selectedIntent = nil
        upiCollectVisible = false
        isQRChevronRotated.toggle()
        upiQRVisible.toggle()
        isCollectChevronRotated = false
    }

    func resetCollect() {
        upiCollectVisible = false
        upiQRVisible = false
        isQRChevronRotated = false
        isCollectChevronRotated = false
    }
}
