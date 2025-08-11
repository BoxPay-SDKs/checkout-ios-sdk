//
//  GeneralPaymentInitilizationResponse.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import UIKit


struct GeneralPaymentInitilizationResponse: Codable,Sendable {
    let message : String?
    let transactionId: String
    let status: GeneralStatusResponse
    let actions: [GeneralActionResponse]
    let transactionTimestampLocale : String
    
    struct GeneralStatusResponse: Codable,Sendable {
        let operation: String
        let status: String
        let reason: String
        let reasonCode: String
    }
}

struct GeneralActionResponse: Codable,Sendable {
    let method: String?
    let url: String?
    let type: String?
    let htmlPageString : String?
}

struct ApiErrorResponse: Codable, Error {
    let errorCode: String
    let message: String
    let fieldErrorItems: [FieldErrorItem]
}

struct FieldErrorItem: Codable {
    let message: String
    let fieldErrorCode: String
}

struct EmptyResponse: Decodable,Sendable {}

struct DeliveryAddressErrorHandlingData {
    var errorMessage: String
    var isTextValid: Bool
    var defaultMessage: String
}
