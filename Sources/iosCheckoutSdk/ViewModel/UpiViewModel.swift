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

    let checkoutManager = CheckoutManager.shared
    let userDataManager = UserDataManager.shared
    let apiManager = ApiService.shared

    func initiateUpiPostRequest(_ selectedIntent: String?, _ shopperVpa: String?, methodType: String) {
        self.isLoading = true
        Task {
            var instrumentDetails: [String: Any] = [
                "type": selectedIntent != nil ? "upi/intent" : "upi/collect"
            ]

            if let intent = selectedIntent {
                instrumentDetails["upiAppDetails"] = ["upiApp": intent]
            } else if let vpa = shopperVpa {
                instrumentDetails["upi"] = ["shopperVpa": vpa]
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

            let isDeliveryEmpty = deliveryAddress.values.allSatisfy { ($0 as? String)?.isEmpty ?? true }

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
                  let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
                print("❌ Invalid JSON")
                await MainActor.run { self.isLoading = false }
                return
            }

            do {
                let response: GeneralPaymentInitilizationResponse = try await apiManager.request(
                    method: .POST,
                    headers: [
                        "Content-Type": "application/json",
                        "X-REQUEST-ID": CommonFunctions.generateRandomAlphanumericString(length: 10)
                    ],
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )

                await self.checkoutManager.setStatus(response.status.status.uppercased())
                await self.checkoutManager.setTransactionId(response.transactionId)
                self.actions = CommonFunctions.handle(
                    timeStamp: response.transactionTimestampLocale,
                    reasonCode: response.status.reasonCode,
                    reason: response.status.reason,
                    methodType: methodType,
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

                self.actions = CommonFunctions.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
                print("❌ Error occurred: \(error)")
            }
        }
        self.isLoading = false
    }
}
