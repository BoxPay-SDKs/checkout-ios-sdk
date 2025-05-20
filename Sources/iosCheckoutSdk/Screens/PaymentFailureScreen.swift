//
//  PaymentFailureScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import Lottie


struct PaymentFailureScreen: View {
    @Binding var reason: String
    var onRetryPayment: () -> Void
    var onReturnToPaymentOptions: () -> Void
    var brandColor:String
    
    var body: some View {
        VStack(spacing: 20) {
            // Warning Icon
            LottieView(animation: .named("PaymentFailed",bundle: .module))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .frame(width: 80, height: 80)
            
            // Title
            Text("Payment Failed")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(Color(hex: "#E84142"))
            
            // Message
            VStack(spacing: 10) {
                Text(reason)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color(hex: "#000000").opacity(0.85))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    // Retry Payment Action
                    onRetryPayment()
                }) {
                    Text("Retry Payment")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(hex: brandColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            
        }
        .padding(.bottom, 20)
    }
}
