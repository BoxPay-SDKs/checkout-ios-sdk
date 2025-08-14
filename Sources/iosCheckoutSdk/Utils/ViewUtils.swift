//
//  ViewUtils.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/07/25.
//

import SwiftUI

extension View {
    func commonCardStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal, 16)
    }
    
    func addPromptView(text: String, brandColor : String) -> some View {
        HStack {
            Image(frameworkAsset: "add_green", isTemplate: true)
                .foregroundColor(Color(hex: brandColor))
                .frame(width:16, height:16)
            Text(text)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: brandColor))
            Spacer()
            Image(frameworkAsset: "chevron")
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(90))
        }
        .padding(12)
        .commonCardStyle()
    }
}
