//
//  SessionExpireScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 23/01/25.
//


import SwiftUI


struct SessionExpireScreen: View {
    var message: String = "For your security, your session has expired due to inactivity. Please restart the payment process."
    var onGoBackToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Warning Icon
            Image(frameworkAsset: "session_expired_orange_timer")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.red)
            
            // Title
            Text("Payment session has expired.")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#DB7C1D"))
            
            // Message
            VStack(spacing: 10) {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
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
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            
        }
        .padding()
    }
}

// Preview
struct SessionExpireScreen_Previews: PreviewProvider {
    static var previews: some View {
        SessionExpireScreen(
            onGoBackToHome: {
                print("Go Back tapped")
            }
        )
    }
}
