//
//  APIServiceSessionApi.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 30/01/25.
//


class APIServiceSessionApi {
    
    func getCheckoutSession(token: String, completion: @escaping (Result<CheckoutSession, Error>) -> Void) {
        let apiManager = APIManager()
        let baseUrl = apiManager.getBaseURL() + "v0/checkout/sessions/"
        guard let url = URL(string: baseUrl + token) else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let checkoutSession = try JSONDecoder().decode(CheckoutSession.self, from: data)
                completion(.success(checkoutSession))
            } catch {
                // Print the error for debugging
                print("Decoding error: \(error)")
                // Optionally, print the raw JSON for verification
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
