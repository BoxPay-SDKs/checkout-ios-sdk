//
//  MorePaymentContainer.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI

struct MorePaymentContainer : View {
    let handleButtonClick : () -> ()
    var image : String
    var title : String
    
    var body: some View {
        VStack {
            Button(action: {
                handleButtonClick()
            }) {
                HStack(alignment: .center) {
                    Image(frameworkAsset: image)
                        .frame(width: 32, height: 32) // Consistent icon size

                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(Color(hex: "#363840"))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(frameworkAsset: "chevron")
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(90))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}
