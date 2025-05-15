//
//  FooterView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUICore


struct FooterView: View{
    var body: some View {
        HStack(alignment: .center){
            Text("Secured by")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(Color(hex: "#888888"))
            Image(frameworkAsset: "boxpay_logo") // Replace with your asset name
                .resizable()
                .frame(width: 50, height: 30)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
