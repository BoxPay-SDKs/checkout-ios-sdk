//
//  LeadingViewType.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 02/06/25.
//


enum LeadingViewType {
    case icon(name: String)
    case picker(options: [String], onSelect: (String) -> Void)
}
