//
//  CardInfoResponse.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

struct CardInfoResponse : Codable {
    let paymentMethod : PaymentMethod
    let methodEnabled : Bool
    let issuerName : String?
    let issuerTitle : String?
    
    struct PaymentMethod : Codable {
        let id : String
        let type:String?
        let brand : String?
        let classification: String?
        let subBrand : String?
    }
}
