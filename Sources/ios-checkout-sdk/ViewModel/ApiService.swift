//
//  ApiService.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

@MainActor
public class ApiService {
    
    static let shared = ApiService()
    private init() {}

    private func constructURL(endpoint: String? = nil) -> String {
        let baseURL = CheckoutManager.shared.getBaseURL()
        let token = CheckoutManager.shared.getMainToken()
        var fullPath = "\(baseURL)/v0/checkout/sessions/\(token)"
        
        if let endpoint = endpoint, !endpoint.isEmpty {
            fullPath += "/\(endpoint)"
        }

        return fullPath
    }

    func request<T: Decodable>(
        endpoint: String? = nil,
        method: HTTPMethod = .GET,
        headers: [String: String] = ["Content-Type": "application/json"],
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let urlString = constructURL(endpoint: endpoint)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decoded))
            } catch {
                // Try to parse the error message from the response
                if let errorMessage = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) {
                    print("API Error Message: \(errorMessage.message)")
                    completion(.failure(NSError(domain: errorMessage.message, code: -3)))
                } else {
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Raw response: \(raw)")
                    }
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
