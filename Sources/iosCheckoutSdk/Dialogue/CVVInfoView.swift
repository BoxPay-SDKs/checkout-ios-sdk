//
//  CVVInfoView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI

struct CVVInfoView: View {
    var onGoBack: () -> Void
    var brandColor : String
    
    var body: some View {
        VStack(alignment:.leading,spacing: 0) {
            Text("Where to find CVV?")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color(hex: "#2D2B32"))
            
            Image(frameworkAsset: "ic_where_to_find_cvv") // Placeholder for card image
                .frame(width: 120, height: 56)
                .padding(.top, 28)
            
            Text("Generic position for CVV")
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#2D2B32"))
                .padding(.top, 16)
            
            Text("3-digit numeric code on the back side of card")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color(hex: "#4F4D55"))
                .padding(.top, 4)
            
            Divider().padding(.vertical, 28)
            
            Image(frameworkAsset: "ic_where_to_find_cvv_amex") // Placeholder for card image
                .frame(width: 120, height: 56)
            
            Text("CVV for American Express Card")
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#2D2B32"))
                .padding(.top, 16)
            
            Text("4-digit numeric code on the front side of the card, just above the card number")
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color(hex: "#4F4D55"))
                .padding(.top, 4)
            
            Button(action: {
                onGoBack()
            }){
                Text("Got it")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: brandColor))
                    .cornerRadius(8)
                    .font(.custom("Poppins-Regular", size: 16))
            }
            .padding(.top, 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}
