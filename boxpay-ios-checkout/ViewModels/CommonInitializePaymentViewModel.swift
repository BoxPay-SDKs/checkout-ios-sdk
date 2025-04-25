////
////  CommonInitializePaymentViewModel 2.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 06/02/25.
////
////  Used to initialize payment in WalletPaymentScreen, NetBankingScreen and BNPLPaymentScreen
//
//import SwiftUI
//import Foundation
//import Combine
//
//
//class CommonInitializePaymentViewModel: ObservableObject {
//    
//    @Published var statusMessage: String?
//    @Published var redirectURL: String?
//    @Published var errorMessage: String?
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func postRequest(
//        InstrumentTypeValue: String,
//        isLoading: Binding<Bool>,
//        showFailureScreen: Binding<Bool>,
//        screenName: String,
//        cardlessEmiProvider: String? = nil // ✅ Added Optional Parameter
//    ) {
////        let apimanager = APIManager()
////        let baseURL = apimanager.getBaseURL()
////        let token = "v0/checkout/sessions/" + apimanager.getMainToken()
////        let primaryToken = apimanager.getMainToken()
////        var instrumentDetails: [String: Any] = [:]
////
////        guard let url = URL(string: "\(baseURL)\(token)") else {
////            print("❌ Invalid URL")
////            return
////        }
////
////        if screenName == "WalletScreen" {
////            instrumentDetails = [
////                "type": InstrumentTypeValue,
////                "wallet": [
////                    "token": primaryToken
////                ]
////            ]
////        } else if screenName == "NetBankingScreen" || screenName == "BNPLScreen" {
////            instrumentDetails = [
////                "type": InstrumentTypeValue
////            ]
////        } else if screenName == "EMI_CARDLESS", let provider = cardlessEmiProvider {  // ✅ Use the extra argument only for EMI_CARDLESS
////            instrumentDetails = [
////                "type": InstrumentTypeValue,
////                "emi": [
////                    "provider": provider
////                ]
////            ]
////        }
////
////        let requestBody: [String: Any] = [
////            "browserData": [
////                "screenHeight": "2324",
////                "screenWidth": "1080",
////                "acceptHeader": "application/json",
////                "userAgentHeader": "Mozilla/5.0 (Linux; Android 13; V2055 Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.135 Mobile Safari/537.36",
////                "browserLanguage": "en_US",
////                "ipAddress": "null",
////                "colorDepth": 24,
////                "javaEnabled": true,
////                "timeZoneOffSet": 330,
////                "packageId": "com.boxpay.checkoutdemoapp"
////            ],
////            "instrumentDetails": instrumentDetails,
////            "shopper": [
////                "email": "testing@bixpay.com",
////                "firstName": "testing",
////                "gender": NSNull(),
////                "lastName": "testing_last_name",
////                "phoneNumber": "+919999999999",
////                "uniqueReference": "x123y"
////            ]
////        ]
////
////        // Configure the request
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////        request.setValue("application/json", forHTTPHeaderField: "Accept")
////        request.setValue(generateRandomAlphanumericString(10), forHTTPHeaderField: "X-Request-Id")
////        request.setValue("iOS SDK", forHTTPHeaderField: "X-Client-Connector-Name")
////        request.setValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version") // Replace with actual SDK version
////
////        // Convert the request body to JSON data
////        do {
////            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
////            request.httpBody = jsonData
////        } catch {
////            print("Error encoding request body: \(error.localizedDescription)")
////            errorMessage = "Failed to encode request data"
////            isLoading.wrappedValue = false
////            showFailureScreen.wrappedValue = true
////            return
////        }
////
////        // Log the request body for debugging
////        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
////            print("Request Body: \(bodyString)")
////        }
////
////        // Perform the network request
////        isLoading.wrappedValue = true
////        URLSession.shared.dataTaskPublisher(for: request)
////            .tryMap { data, response -> Data in
////                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
////                    print("HTTP Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
////                    throw URLError(.badServerResponse)
////                }
////                return data
////            }
////            .decode(type: GeneralPaymentInitilizationResponse.self, decoder: JSONDecoder())
////            .receive(on: DispatchQueue.main)
////            .sink(receiveCompletion: { [weak self] completion in
////                switch completion {
////                case .failure(let error):
////                    print("Request failed with error: \(error.localizedDescription)")
////                    self?.errorMessage = error.localizedDescription
////                    showFailureScreen.wrappedValue = true
////                    isLoading.wrappedValue = false
////                case .finished:
////                    print("Request finished successfully")
////                }
////            }, receiveValue: { [weak self] response in
////                self?.statusMessage = response.status.reason
////                self?.redirectURL = response.actions.first?.url
////                print("Status: \(response.status.reason)")
////                print("Redirect URL: \(response.actions.first?.url ?? "Not available")")
////
////                if response.status.reason == "Approved" {
////                    print("Payment Approved")
////                } else if !response.actions.isEmpty {
////                    let actionURL = response.actions.first?.url ?? ""
////                    print("Redirect to URL: \(actionURL)")
////                } else {
////                    print("Payment requires further action or failed.")
////                }
////            })
////            .store(in: &cancellables)
//    }
//
//    
//    // Helper function to generate random alphanumeric string
//    private func generateRandomAlphanumericString(_ length: Int) -> String {
//        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        return String((0..<length).compactMap { _ in characters.randomElement() })
//    }
//}
