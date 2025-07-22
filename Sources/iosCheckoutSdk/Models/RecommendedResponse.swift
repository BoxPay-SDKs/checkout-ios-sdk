//
//  RecommendedResponse.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 23/05/25.
//

struct RecommendedResponse : Codable, Sendable {
    let shopperRef : String?
    let type : String?
    let brand : String?
    let instrumentType : String?
    let instrumentRef : String?
    let value : String?
    let displayValue : String?
    let lastUsed : String?
    let logoUrl : String?
    let cardNickName : String?
}
