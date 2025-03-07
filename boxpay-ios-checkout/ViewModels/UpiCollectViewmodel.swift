//
//  UpiCollectViewmodel.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 04/02/25.
//

import Foundation
import SwiftUI

class UpiCollectViewmodel: ObservableObject {
    @Published var isUPIValid: Bool = false
    @Published var isUPIInvalid: Bool = false
    @Published var isLoading: Bool = false
    
    // Use this function to trigger the UPI validation
    func validateVpa(userVPA: String, legalEntity: String, merchantId: String, countryCode: String) {
        isLoading = true
        isUPIValid = false
        isUPIInvalid = false
        let apimanager = APIManager()
        let baseURL = apimanager.getBaseURL() // Replace with your API URL
        guard let url = URL(string: "\(baseURL)/v0/platform/vpa-validation") else {
            return
        }
        
        // Construct the request body
        let requestBody: [String: Any] = [
            "vpa": userVPA,
            "legalEntity": legalEntity,
            "merchantId": merchantId,
            "countryCode": countryCode
        ]
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
        // Add any other headers here if needed (uncomment below lines)
        // request.setValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        // request.setValue(BuildConfig.SDK_VERSION, forHTTPHeaderField: "X-Client-Connector-Version")
        
        // Serialize the JSON body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("API request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isUPIValid = false
                    self?.isUPIInvalid = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self?.isUPIValid = false
                    self?.isUPIInvalid = false
                }
                return
            }
            
            // Handle response data
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let vpaValid = jsonResponse["vpaValid"] as? Bool {
                    DispatchQueue.main.async {
                        if vpaValid {
                            self?.isUPIValid = true
                            self?.isUPIInvalid = false
                            self?.initializeUpiCollectPayment(dynamicshopperVpa: userVPA) { result in
                                switch result {
                                case .success(let response):
                                    print("Transaction ID: \(response.transactionId)")
                                    print("Status: \(response.status.status)")
                                    // Handle success
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                    // Handle error
                                }
                            }
                            // Call the postRequest function or do something when UPI is valid
                        } else {
                            self?.isUPIValid = false
                            self?.isUPIInvalid = true
                            self?.initializeUpiCollectPayment(dynamicshopperVpa: userVPA) { result in
                                switch result {
                                case .success(let response):
                                    print("Transaction ID: \(response.transactionId)")
                                    print("Status: \(response.status.status)")
                                    // Handle success
                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                                    // Handle error
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.isUPIValid = false
                        self?.isUPIInvalid = false
                        self?.initializeUpiCollectPayment(dynamicshopperVpa: userVPA) { result in
                            switch result {
                            case .success(let response):
                                print("Transaction ID: \(response.transactionId)")
                                print("Status: \(response.status.status)")
                                // Handle success
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                                // Handle error
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isUPIValid = false
                    self?.isUPIInvalid = false
                    self?.initializeUpiCollectPayment(dynamicshopperVpa: userVPA) { result in
                        switch result {
                        case .success(let response):
                            print("Transaction ID: \(response.transactionId)")
                            print("Status: \(response.status.status)")
                            // Handle success
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                            // Handle error
                        }
                    }
                }
            }
        }.resume()
    }
    
    public func initializeUpiCollectPayment(dynamicshopperVpa: String, completion: @escaping (Result<ApiResponseUpiCollect, Error>) -> Void) {
        let apimanager = APIManager()
        let baseURL = apimanager.getBaseURL()
        let token = "v0/checkout/sessions/" + apimanager.getMainToken()
        
        guard let url = URL(string: "\(baseURL)\(token)") else {
            print("❌ Invalid URL")
            return
        }
        
        let requestBody: [String: Any] = [
            "browserData": [
                "screenHeight": "2324",
                "screenWidth": "1080",
                "acceptHeader": "application/json",
                "userAgentHeader": "Mozilla/5.0 (Linux; Android 13; V2055 Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.135 Mobile Safari/537.36",
                "browserLanguage": "en_US",
                "ipAddress": "null",
                "colorDepth": 24,
                "javaEnabled": true,
                "timeZoneOffSet": 330,
                "packageId": "com.boxpay.checkoutdemoapp"
            ],
            "instrumentDetails": [
                "type": "upi/collect",
                "upi": [
                    "shopperVpa": dynamicshopperVpa
                ]
            ],
            "shopper": [
                "email": "testing@boxpay.com",
                "firstName": "testing",
                "gender": NSNull(),
                "lastName": "testing_last_name",
                "phoneNumber": "+919999999999",
                "uniqueReference": "x123y"
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted) else {
            print("❌ Failed to serialize request body")
            completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
            return
        }
        
        print("📤 Request Body:\n", String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Session \(UserDefaults.standard.string(forKey: "shopperToken") ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.setValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:\n", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ApiResponseUpiCollect.self, from: data)
                print("✅ Response Body:\n", String(data: data, encoding: .utf8) ?? "Invalid JSON")
                completion(.success(responseObject))
            } catch {
                print("❌ Decoding Error:\n", error.localizedDescription)
                print("📥 Response Body:\n", String(data: data, encoding: .utf8) ?? "Invalid JSON")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    
    // Helper function to generate random alphanumeric string (simulating the X-Request-Id header)
    func generateRandomAlphanumericString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
}


import Foundation

// Root model for the response
struct ApiResponseUpiCollect: Codable {
    let transactionId: String
    let transactionTimestamp: String
    let status: Status
    let actions: [Action]
    let additionalData: AdditionalDataUpiCollect
    let paymentMethod: PaymentMethodUpiCollect
    let transactionTimestampLocale: String
}

// Model for the "status" field
struct Status: Codable {
    let operation: String
    let status: String
    let reason: String
    let reasonCode: String
}

// Model for the "actions" field
struct Action: Codable {
    // Define fields if any, based on the "actions" structure in the response
}

// Model for the "additionalData" field
struct AdditionalDataUpiCollect: Codable {
    let shopperVpa: String
}

// Model for the "paymentMethod" field
struct PaymentMethodUpiCollect: Codable {
    let type: String
    let brand: String
}
