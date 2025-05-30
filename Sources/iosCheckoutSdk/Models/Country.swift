//
//  Country.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//


struct Country: Codable {
    let fullName: String
    let isdCode: String
    let phoneNumberLength: [Int]
    let threeLetterCode: String
}
