//
//  GeneralPaymentInitilizationResponse.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 06/02/25.
//


struct GeneralPaymentInitilizationResponse: Codable {
    let transactionId: String
    let transactionTimestamp: String
    let status: GeneralStatusResponse
    let actions: [GeneralActionResponse]
    
    struct GeneralStatusResponse: Codable {
        let operation: String
        let status: String
        let reason: String
        let reasonCode: String
    }
    
    struct GeneralActionResponse: Codable {
        let method: String
        let url: String
        let type: String
    }
}






// MARK: - Codable Structs
struct RequestBody: Codable {
    let browserData: BrowserData
    let instrumentDetails: InstrumentDetails
    let shopper: ShopperCardView
    let deviceDetails: DeviceDetails
    let offers: [String]? // Added offers array
}

struct BrowserData: Codable {
    let screenHeight: String
    let screenWidth: String
    let acceptHeader: String
    let userAgentHeader: String
    let browserLanguage: String
    let ipAddress: String
    let colorDepth: Int
    let javaEnabled: Bool
    let timeZoneOffSet: Int
    let packageId: String
}

struct InstrumentDetails: Codable {
    let type: String
    let card: Card
    let emi: EMI? // Added optional EMI field
}

struct Card: Codable {
    let number: String
    let expiry: String
    let cvc: String
    let holderName: String
}

struct EMI: Codable {
    let duration: Int
}

struct ShopperCardView: Codable {
    let firstName: String
    let lastName: String
    let gender: String?
    let phoneNumber: String
    let email: String
    let uniqueReference: String
    let dateOfBirth: String
    let panNumber: String
}

struct DeviceDetails: Codable {
    let browser: String
    let platformVersion: String
    let deviceType: String
    let deviceName: String
    let deviceBrandName: String
}

