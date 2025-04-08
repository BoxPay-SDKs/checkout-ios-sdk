//
//  APIManager.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 14/01/25.
//


import Foundation

class APIManager {

    private let baseURLKey = "BaseURLKey"
    private let mainTokenKey = "mainTokenKey"
    private let shopperTokenKey = "shopperTokenKey"

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
    
    func getMainToken() -> String {
        let defauktToken = ""
        if let savedToken = UserDefaults.standard.string(forKey: mainTokenKey) {
            return savedToken
        } else {
            return defauktToken
        }
    }
    
    func getShopperToken() -> String {
        let defaultShopperToken = ""
        if let savedShopperToken = UserDefaults.standard.string(forKey: shopperTokenKey) {
            return savedShopperToken
        } else {
            return defaultShopperToken
        }
    }

    // Set a new base URL (in UserDefaults)
    func setBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: baseURLKey)
    }
    
    func setMainToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: mainTokenKey)
    }
    
    func setShopperToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: shopperTokenKey)
    }
    
    // Example API endpoint that uses the current base URL
    // not used anywhere
    func getAPIEndpoint() -> String {
        return getBaseURL() + "/v0/merchants/oh3mnorsME/sessions"
    }
}
