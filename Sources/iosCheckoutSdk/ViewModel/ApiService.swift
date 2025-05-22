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

public actor ApiService {
    
    static let shared = ApiService()
    private init() {}

    private func constructURL(endpoint: String? = nil) async -> String {
        let baseURL = await CheckoutManager.shared.getBaseURL()
        let token = await CheckoutManager.shared.getMainToken()
        
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
        responseType: T.Type
    ) async throws -> T {
        let urlString = await constructURL(endpoint: endpoint)
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            let decoded = try JSONDecoder().decode(responseType, from: data)
            return decoded
        } catch {
            // Try to parse error message from response
            if let errorMessage = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) {
                throw NSError(domain: errorMessage.message, code: -3)
            } else {
                throw error
            }
        }
    }
}
