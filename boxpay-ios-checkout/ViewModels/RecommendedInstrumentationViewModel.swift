////
////  RecommendedInstrumentationViewModel.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 10/03/25.
////
//
//
//import Foundation
//import Combine
//
//class RecommendedInstrumentationViewModel: ObservableObject {
////    @Published var recommendedInstruments: [RecommendedPaymentInstrument] = []
//    @Published var errorMessage: String?
////    private var apiManager = APIManager()
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func fetchRecommendedInstruments(token: String, shopperToken: String, shopperReference: String) {
////        guard !token.isEmpty, !shopperToken.isEmpty else {
////            errorMessage = "Invalid token or shopper token"
////            return
////        }
////
////        guard let url = URL(string: getRecommendedInstrumentEndpoint(token: token, shopperToken: shopperToken, shopperReference: shopperReference)) else {
////            print("❌ Invalid URL")
////            return
////        }
////
////    
////        var request = URLRequest(url: url)
////        request.httpMethod = "GET"
////        request.addValue("Session \(shopperToken)", forHTTPHeaderField: "Authorization")
////
////        URLSession.shared.dataTaskPublisher(for: request)
////            .tryMap { data, response -> Data in
////                guard let httpResponse = response as? HTTPURLResponse else {
////                    throw URLError(.badServerResponse)
////                }
////
////                print("🔍 Status Code: \(httpResponse.statusCode)")
////                if httpResponse.statusCode != 200 {
////                    let body = String(data: data, encoding: .utf8) ?? "No response body"
////                    print("❌ Server Response Body: \(body)")
////                    throw URLError(.badServerResponse)
////                }
////
////                return data
////            }
////            .decode(type: [RecommendedPaymentInstrument].self, decoder: JSONDecoder())
////            .receive(on: DispatchQueue.main)
////            .sink(receiveCompletion: { completion in
////                switch completion {
////                case .failure(let error):
////                    self.errorMessage = error.localizedDescription
////                    print("❌ Error: \(error.localizedDescription)")
////                case .finished:
////                    print("✅ Successfully fetched instruments")
////                }
////            }, receiveValue: { instruments in
////                self.recommendedInstruments = instruments
////                
////                // ✅ Print fetched items
////                print("🔹 Fetched Recommended Instruments:")
////            })
////            .store(in: &cancellables)
//
//    }
//    
//    func getRecommendedInstrumentEndpoint(token: String, shopperToken: String , shopperReference: String) -> String {
////        let apiManager = APIManager()
////        let baseURL = apiManager.getBaseURL()
////        return baseURL + "v0/checkout/sessions/\(token)/shoppers/\(shopperReference)/recommended-instruments"
//        return ""
//    }
//
//}
//
