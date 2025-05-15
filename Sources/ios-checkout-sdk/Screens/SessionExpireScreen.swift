//
//  SessionExpireScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import Lottie


struct SessionExpireScreen: View {
    var message: String = "For your security, your session has expired due to inactivity. Please restart the payment process."
    var brandColor:String
    var onGoBackToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Warning Icon
            LottieView(animation: .named("SessionExpired"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .frame(width: 80, height: 80)
            
            // Title
            Text("Payment session has expired.")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(Color(hex: "#DB7C1D"))
            
            // Message
            VStack(spacing: 10) {
                Text(message)
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
                    onGoBackToHome()
                }) {
                    Text("Go Back")
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
