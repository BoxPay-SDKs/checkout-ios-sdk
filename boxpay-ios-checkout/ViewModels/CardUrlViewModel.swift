//
//  CardUrlViewModel.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 04/02/25.
//

import SwiftUI
import Combine
class CardUrlViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var redirectURL: String?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCardPaymentUrl(isLoading: Binding<Bool>, showFailureScreen: Binding<Bool>, cardNumber: String, cvv: String, expiry: String, cardHolderName: String, emi: PaymentMethod?, saveCard : Bool) {
        isLoading.wrappedValue = true
        let apiManager = APIManager()
        guard let url = URL(string: "\(apiManager.getBaseURL())v0/checkout/sessions/\(apiManager.getMainToken())") else {
            errorMessage = "Invalid URL"
            isLoading.wrappedValue = false
            showFailureScreen.wrappedValue = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
        request.addValue("iOS SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")

        // Default values
        var offers: [String] = []
        var instrumentDetails: [String: Any] = [
            "type": "card/plain",
            "card": [
                "number": cardNumber,
                "expiry": expiry,
                "cvc": cvv,
                "holderName": cardHolderName
            ],
            "saveInstrument": saveCard
        ]

        // If EMI exists, modify the instrument details and add offer codes
        if let emi = emi {
            instrumentDetails["type"] = "emi/cc"
            instrumentDetails["emi"] = ["duration": emi.emiMethod?.duration ?? 3]

            if let firstOffer = emi.applicableOffers?.first {
                switch firstOffer {
                case .string(let code):
                    offers.append(code)
                case .object(let details):
                    if let code = details.code {
                        offers.append(code)
                    }
                }
            }
        }

        // Construct JSON request body manually
        var requestBody: [String: Any] = [
            "browserData": [
                "screenHeight": "2324",
                "screenWidth": "1080",
                "acceptHeader": "application/json",
                "userAgentHeader": "Mozilla/5.0 (Linux; Android 13; V2055 Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.86 Mobile Safari/537.36",
                "browserLanguage": "en_US",
                "ipAddress": "null",
                "colorDepth": 24,
                "javaEnabled": true,
                "timeZoneOffSet": 330,
                "packageId": "com.boxpay.checkout.demoapp"
            ],
            "instrumentDetails": instrumentDetails,
            "shopper": [
                "firstName": "Ankush",
                "lastName": "Kashyap",
                "gender": nil,
                "phoneNumber": "+919911103562",
                "email": "ankush.kashyap@boxpay.tech",
                "uniqueReference": "x123y",
                "dateOfBirth": "2024-11-14T10:31:00Z",
                "panNumber": "CTGPA0002G"
            ],
            "deviceDetails": [
                "browser": "vivo",
                "platformVersion": "13",
                "deviceType": "vivo",
                "deviceName": "vivo",
                "deviceBrandName": "V2055"
            ]
        ]

        // ✅ Add "offers" only if it's not empty
        if !offers.isEmpty {
            requestBody["offers"] = offers
        }

        // Convert to JSON Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            isLoading.wrappedValue = false
            showFailureScreen.wrappedValue = true
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ Request JSON: \(jsonString)")
            }
        } catch {
            print("❌ Error serializing JSON: \(error.localizedDescription)")
            errorMessage = "Failed to encode request data"
            isLoading.wrappedValue = false
            showFailureScreen.wrappedValue = true
            return
        }


        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid HTTP Response")
                    throw URLError(.badServerResponse)
                }

                print("🔹 HTTP Status Code: \(httpResponse.statusCode)")
                print("🔹 HTTP Headers: \(httpResponse.allHeaderFields)")

                guard httpResponse.statusCode == 200 else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    print("❌ Error Response Body: \(responseString)")
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .decode(type: GeneralPaymentInitilizationResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("❌ Request failed with error: \(error.localizedDescription)")

                    // Additional error details
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let key, let context):
                            print("❌ Type Mismatch: \(key) - \(context.debugDescription)")
                        case .valueNotFound(let key, let context):
                            print("❌ Value Not Found: \(key) - \(context.debugDescription)")
                        case .keyNotFound(let key, let context):
                            print("❌ Key Not Found: \(key) - \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("❌ Data Corrupted: \(context.debugDescription)")
                        default:
                            print("❌ Unknown Decoding Error: \(error.localizedDescription)")
                        }
                    }

                    // Print response body in case of decoding failure
                    if let responseData = try? JSONSerialization.jsonObject(with: request.httpBody ?? Data(), options: []) {
                        print("📜 Request Body Sent: \(responseData)")
                    }

                    self?.errorMessage = error.localizedDescription
                    showFailureScreen.wrappedValue = true

                case .finished:
                    print("✅ Request finished successfully")
                }
            }, receiveValue: { [weak self] response in
                self?.statusMessage = response.status.reason
                self?.redirectURL = response.actions.first?.url

                print("✅ Status: \(response.status.reason)")
                print("✅ Redirect URL: \(response.actions.first?.url ?? "Not available")")
            })
            .store(in: &cancellables)

    }
    
    
    func fetchDCCQuotation(
        isLoading: Binding<Bool>,
        dccRequest: DCCRequest,
        completion: @escaping (Result<DCCResponse, Error>) -> Void
    ) {
        isLoading.wrappedValue = true
        let apiManager = APIManager()
        guard let url = URL(string: "\(apiManager.getBaseURL())v0/checkout/sessions/\(apiManager.getMainToken())/dcc/quotations") else {
            errorMessage = "Invalid URL"
            isLoading.wrappedValue = false
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
        request.addValue("iOS SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")

        // ✅ Convert `DCCRequest` object to JSON data using JSONEncoder
        do {
            let jsonData = try JSONEncoder().encode(dccRequest)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ DCC Request JSON: \(jsonString)")
            }
        } catch {
            print("❌ Error encoding JSON: \(error.localizedDescription)")
            errorMessage = "Failed to encode request data"
            isLoading.wrappedValue = false
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid HTTP Response")
                    throw URLError(.badServerResponse)
                }

                print("🔹 HTTP Status Code: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    print("❌ Error Response Body: \(responseString)")
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .decode(type: DCCResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .failure(let error):
                    print("❌ DCC Request failed with error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    isLoading.wrappedValue = false
                    completion(.failure(error))
                case .finished:
                    print("✅ DCC Request finished successfully")
                    isLoading.wrappedValue = false
                }
            }, receiveValue: { response in
                print("✅ DCC Response: \(response)")
                isLoading.wrappedValue = false
                completion(.success(response))
            })
            .store(in: &cancellables)
    }

    func getDeviceDetails() -> DeviceDetails {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let deviceModel = device.model // Example: "iPhone"
        let deviceName = device.name   // Example: "Ankush's iPhone"
        let deviceBrandName = "Apple"

        return DeviceDetails(
            browser: "Safari", // Default for iOS
            platformVersion: systemVersion,
            deviceType: deviceModel,
            deviceName: deviceName,
            deviceBrandName: deviceBrandName
        )
    }
    
    private func generateRandomAlphanumericString(length: Int) -> String {
        let charPool = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        return String((0..<length).compactMap { _ in charPool.randomElement() })
    }
    
    struct DCCResponse: Codable {
        let dccQuotationId: String?
        let merchantId: String?
        let context: ContextResponse?
        let baseMoney: BaseMoney?
        let dccQuotationDetails: DccQuotationDetails?
        let brand: String?
        let supportedPsps: [String]?
        let addedOn: String?
        let updatedOn: String?
        let addedOnLocale: String?
        let updatedOnLocale: String?
    }

    struct ContextResponse: Codable {
        let legalEntity: LegalEntityResponse?
        let countryCode: String?
        let localeCode: String?
        let clientPosId: String?
        let orderId: String?
        let clientOrgIP: String?
    }

    struct LegalEntityResponse: Codable {
        let code: String?
    }

    struct BaseMoney: Codable {
        let amount: Int?
        let currencyCode: String?
        let amountLocale: String?
        let amountLocaleFull: String?
        let currencySymbol: String?
    }

    struct DccQuotationDetails: Codable {
        let dccMoney: DccMoney?
        let fxRate: Double?
        let marginPercent: Double?
        let commissionPercent: Int?
        let source: String?
        let dspCode: String?
        let dspQuotationReference: String?
    }

    struct DccMoney: Codable {
        let amount: Double?
        let currencyCode: String?
        let amountLocale: String?
        let amountLocaleFull: String?
        let currencySymbol: String?
    }



}
