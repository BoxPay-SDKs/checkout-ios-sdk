//
//  UPIIntentViewModel.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 30/01/25.
//

import Combine
import SwiftUI


class UPIIntentViewModel: ObservableObject {
    @Published var upiIntentURLBase64: String?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUPIIntentURL(appName: String,isLoading: Binding<Bool>) {
        isLoading.wrappedValue = true
        let apimanager = APIManager()
        let baseURL = apimanager.getBaseURL() // Replace with your API URL
        let token = "v0/checkout/sessions/" + apimanager.getMainToken() // Replace with your token
        guard let url = URL(string: "\(baseURL)\(token)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
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
                "type": "upi/intent",
                "upiAppDetails": [
                    "upiApp": appName
                ]
            ],
            "shopper": [
                "email": "testing@bixpay.com",
                "firstName": "testing",
                "gender": NSNull(), // Use NSNull for null values
                "lastName": "testing_last_name",
                "phoneNumber": "+919999999999",
                "uniqueReference": "x123y"
            ]
        ]
        
        // Convert the body to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            print("jsonDataRequest\(jsonData)")
            request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
            request.addValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
            request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")
            request.httpBody = jsonData
        } catch {
            print("Error serializing request body: \(error.localizedDescription)")
            isLoading.wrappedValue = false
            return
        }
        
        // Log the request body for debugging
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        // Perform the request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("HTTP Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    print("UpiIntentError: \(error)")
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    print("Request finished successfully")
                }
            }, receiveValue: { [weak self] response in
                if let urlForIntent = response.actions.first?.url {
                    let base64URL = urlForIntent.data(using: .utf8)?.base64EncodedString()
                    self?.upiIntentURLBase64 = base64URL
                    print("UPI Intent URL (Base666666): \(urlForIntent)")
                    print("UPI Intent URL (Base64): \(base64URL ?? "Not available")")
                    
                    // Call launchUPIIntent directly here
                    self?.launchUPIIntent(base64URL: urlForIntent)
                } else {
                    self?.errorMessage = "Invalid response structure"
                    print("Invalid response structure: No URL found in actions")
                    isLoading.wrappedValue = false
                }
            }
            )
            .store(in: &cancellables)
    }
    
    struct APIResponse: Codable {
        let actions: [Action]
    }
    
    struct Action: Codable {
        let url: String
    }
    
    
    
    func generateRandomAlphanumericString(length: Int) -> String {
        let charPool = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        return String((0..<length).compactMap { _ in charPool.randomElement() })
    }
    
    func launchUPIIntent(base64URL: String) {
        // Step 1: Decode the Base64 string into Data
        guard let decodedData = Data(base64Encoded: base64URL),
              
                // Step 2: Convert the decoded Data into a UTF-8 string
              let urlString = String(data: decodedData, encoding: .utf8),
              
                // Step 3: Convert the string into a URL object
              let uri = URL(string: urlString) else {
            print("Invalid or improperly Base64-decoded UPI URL")
            return
        }
        // Step 5: Ensure the device can handle the URL
        guard UIApplication.shared.canOpenURL(uri) else {
            print("App not available to handle UPI intent: \(uri.absoluteString)")
            return
        }
        
        // Step 6: Launch the app with the decoded URL
        UIApplication.shared.open(uri, options: [:]) { success in
            if success {
                print("UPI app launched successfully with URL: \(uri.absoluteString)")
            } else {
                print("Failure while launching UPI app")
            }
        }
    }
    
    
}
