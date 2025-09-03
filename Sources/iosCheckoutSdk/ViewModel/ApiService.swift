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

    private func constructURL(endpoint: String? = nil, includeToken: Bool, analyticsCall : Bool) async -> String {
        let baseURL = await CheckoutManager.shared.getBaseURL()
        
        var fullPath = analyticsCall ? "\(baseURL)/v0/ui-analytics" : "\(baseURL)/v0/checkout/sessions/"
        
        if !analyticsCall {
            if includeToken {
                let token = await CheckoutManager.shared.getMainToken()
                fullPath += token
            }
            
            if let endpoint = endpoint, !endpoint.isEmpty {
                fullPath += endpoint
            }
        }
        
        return fullPath
    }


    func request<T: Decodable>(
        endpoint: String? = nil,
        includeToken: Bool = true,
        analyticsCall : Bool = false,
        method: HTTPMethod = .GET,
        headers: [String: String] = ["Content-Type": "application/json"],
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        let urlString = await constructURL(endpoint: endpoint, includeToken: includeToken, analyticsCall: analyticsCall)
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)

        do {
            if let apiError = try? JSONDecoder().decode(ApiErrorResponse.self, from: data),
               !(apiError.errorCode.isEmpty && apiError.message.isEmpty && apiError.fieldErrorItems.isEmpty) {
                throw apiError
            }
            
            if (!data.isEmpty) {
                let decoded = try JSONDecoder().decode(responseType, from: data)
                return decoded
            } else {
                return EmptyResponse() as! T
            }
            
        } catch {
            throw error
        }

    }
}
