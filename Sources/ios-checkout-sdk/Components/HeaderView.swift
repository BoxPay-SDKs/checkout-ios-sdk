//
//  HeaderView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUICore
import SwiftUI

struct HeaderView: View {
    var text: String
    var showDesc: Bool
    var showSecure: Bool
    var itemCount: Int
    var currencySymbol: String
    var amount: String
    var onBackPress: (() -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                
                // Back Arrow
                Button(action: {
                    onBackPress()
                }) {
                    Image(frameworkAsset: "arrow-left")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 8)
                }
                
                // Title and Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(text)
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "#363840"))
                    
                    if showDesc {
                        HStack(spacing: 4) {
                            if itemCount > 0 {
                                Text("\(itemCount) \(itemCount == 1 ? "item" : "items") ·")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#4F4D55"))
                            }
                            
                            (
                                Text("Total:")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#4F4D55")) +
                                
                                Text(" \(currencySymbol)")
                                    .font(.custom("Inter-SemiBold", size: 12))
                                    .foregroundColor(Color(hex: "#4F4D55")) +
                                
                                Text(amount)
                                    .font(.custom("Poppins-SemiBold", size: 12))
                                    .foregroundColor(Color(hex: "#4F4D55"))
                            )
                        }
                        .padding(.top, -4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Secure Badge
                if showSecure {
                    HStack(spacing: 4) {
                        Image(frameworkAsset: "Lock")
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Text("100% Secure")
                            .font(.custom("Poppins-SemiBold", size: 12))
                            .foregroundColor(Color(hex: "#1CA672"))
                            .padding(.bottom, 2)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#E8F6F1"))
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            
            Divider()
        }
    }
}
