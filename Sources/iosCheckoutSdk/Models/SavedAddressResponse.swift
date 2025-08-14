//
//  SavedAddressResponse.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 11/08/25.
//

struct SavedAddressResponse : Codable , Sendable {
    let address1 : String
    let address2 : String
    let address3 : String
    let city : String
    let state : String
    let countryCode : String
    let postalCode : String
    let shopperRef : String
    let addressRef : String
    let labelType : String
    let labelName : String
    let name : String
    let email : String
    let phoneNumber : String
}
