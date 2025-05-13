//
//  FetchStatusResponse.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 25/04/25.
//

struct FetchStatusResponse : Codable {
    let status : String
    let statusReason:String?
    let reasonCode:String?
    let transactionId : String?
    let transactionTimestampLocale : String?
}
