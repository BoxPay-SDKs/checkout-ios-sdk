//
//  AnalyticsViewModel.swift
//  boxpay-ios-checkout-sdk
//
//  Created by Ishika Bansal on 03/09/25.
//
import UIKit

@MainActor
class AnalyticsViewModel: ObservableObject {
    private let apiService = ApiService.shared
    private let checkoutManager = CheckoutManager.shared
    
    func callUIAnalytics(_ uiEvent : String, _ screenName : String, _ message : String) {
        Task {
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
                "callerToken": checkoutManager.getMainToken(),
                "uiEvent" : uiEvent,
                "eventAttrs" : [
                    "errorMessage" : message,
                    "screenName" : screenName
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
                let _ = try await apiService.request(
                    analyticsCall: true,
                    method : .POST,
                    body: jsonData,
                    responseType: [AnalyticsResponse].self
                )
            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                print("api error \(errorDescription)")
            }
        }
    }
}
