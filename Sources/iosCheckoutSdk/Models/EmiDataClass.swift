//
//  CardType.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


struct CardType {
    let cardType : String
    let banks : [Bank]
}

struct Bank {
    let iconUrl : String
    let name : String
    let percent : String
    let isNoCostApplied : Bool
    let isLowCostApplied : Bool
    var emiList : [EmiList]
    let cardLessEmiValue : String
    let issuerBrand : String?
}

struct EmiList {
    let duration:Int
    let percent : String
    let amount: String
    let totalAmount:String
    let discount : String?
    let interestCharged : String
    let noCostApplied : Bool
    let lowCostApplied : Bool
    let processingFee : String
    let code: String?
    let netAmount : String
}

struct EmiDataClass {
    let cards : [CardType]
}
