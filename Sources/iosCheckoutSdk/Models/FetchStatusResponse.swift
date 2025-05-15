//
//  FetchStatusResponse.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


struct FetchStatusResponse : Codable {
    let status : String
    let statusReason:String?
    let reasonCode:String?
    let transactionId : String?
    let transactionTimestampLocale : String?
}