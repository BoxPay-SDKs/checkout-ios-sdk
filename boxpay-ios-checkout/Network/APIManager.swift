//
//  APIManager.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 14/01/25.
//


import Foundation

class APIManager {

    private let baseURLKey = "BaseURLKey"

    // Get the current base URL (from UserDefaults)
    func getBaseURL() -> String {
        // Default base URL if none is set
        let defaultBaseURL = "https://apis.boxpay.in"
        // Return the base URL from UserDefaults or the default one
        if let savedURL = UserDefaults.standard.string(forKey: baseURLKey) {
            return savedURL
        } else {
            return defaultBaseURL
        }
    }

    // Set a new base URL (in UserDefaults)
    func setBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: baseURLKey)
    }
    
    // Example API endpoint that uses the current base URL
    // not used anywhere
    func getAPIEndpoint() -> String {
        return getBaseURL() + "/v0/merchants/oh3mnorsME/sessions"
    }
}
