import Foundation
import Combine

class RecommendedInstrumentationViewModel: ObservableObject {
    @Published var recommendedInstrumentationList: [RecommendedPaymentInstrument] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    
    private let apiManager = APIManager()
    private let token: String
    private let shopperRef: String
    
    init(token: String, shopperRef: String) {
        self.token = token
        self.shopperRef = shopperRef
    }
    
    func getRecommendedInstrumentation() {
        guard let url = URL(string: "\(apiManager.getBaseURL())\(token)/shoppers/\(shopperRef)/recommended-instruments") else {
            print("❌ Invalid URL")
            return
        }
        
        isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Session \(apiManager.getCustomerShopperToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("➡️ Request URL: \(url)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                print("🔹 HTTP Status Code: \(httpResponse.statusCode)")
                print("🔹 HTTP Headers: \(httpResponse.allHeaderFields)")
                
                guard httpResponse.statusCode == 200 else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    print("❌ Error Response: \(responseString)")
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [RecommendedPaymentInstrument].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Request Failed: \(error.localizedDescription)")
                case .finished:
                    print("✅ Request Succeeded")
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] response in
                print("✅ Response: \(response)")
                
                // ✅ Limit to max 2 items
                self?.recommendedInstrumentationList = Array(response.prefix(2))
                
                // ✅ Handle UI State Based on Results
                if let list = self?.recommendedInstrumentationList, !list.isEmpty {
                    print("✅ Recommended Instruments: \(list)")
                    self?.handleSuccess()
                } else {
                    print("✅ No recommended instruments found")
                    self?.handleFailure()
                }
            })
            .store(in: &cancellables)
    }
    
    private func handleSuccess() {
        // ✅ Handle success state (like showing buttons or views)
        print("✅ Success - Showing options")
    }
    
    private func handleFailure() {
        // ✅ Handle failure state (like showing alternative options)
        print("✅ No instruments available - Showing UPI Options")
    }
}
