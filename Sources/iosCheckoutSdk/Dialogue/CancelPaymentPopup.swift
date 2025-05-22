//
//  CancelPaymentPopup.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI

struct CancelPaymentPopup: View {
    var onCancel: () -> Void
    var onDismiss: () -> Void
    var brandColor :String

    var body: some View {
        VStack {
            Text("Are you sure you want to cancel payment?")
                .font(.custom("Poppins-SemiBold", size: 17))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top, 35)
                .padding(.horizontal, 16)

            Text("This payment request cancels only if you haven't finished the payment")
                .font(.custom("Poppins-Regular", size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "#4F4D55"))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 18)

            Divider()

            Button(action: onCancel) {
                Text("Yes, cancel")
                    .font(.custom("Poppins-SemiBold", size: 17))
                    .foregroundColor(Color(hex: brandColor))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)

            Divider()

            Button(action: onDismiss) {
                Text("No")
                    .font(.custom("Poppins-Regular", size: 15))
                    .foregroundColor(Color(hex: "#4F4D55"))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: 320)
        .shadow(radius: 8)
    }
}
