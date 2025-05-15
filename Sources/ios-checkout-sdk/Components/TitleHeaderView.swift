//
//  TitleHeaderView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUICore

struct TitleHeaderView : View {
    var text:String
    var body: some View {
        HStack {
            Text(text)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#020815").opacity(0.71))
            // Optional logo image
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .padding(.top, 16)
    }
}
