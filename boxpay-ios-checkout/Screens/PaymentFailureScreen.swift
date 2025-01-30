//
//  PaymentFailureScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 22/01/25.
//

import SwiftUI


struct PaymentFailureScreen: View {
    var message: String = "You may have canceled the payment or there was a delay in response from the Bank's page."
    var onRetryPayment: () -> Void
    var onReturnToPaymentOptions: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Warning Icon
            Image(frameworkAsset: "failure_alert_red")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            
            // Title
            Text("Payment Failed")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            // Message
            VStack(spacing: 10) {
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                
                Text("Please retry payment or try using other methods.")
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
                    onRetryPayment()
                }) {
                    Text("Retry Payment")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Return to Payment Options Action
                    onReturnToPaymentOptions()
                }) {
                    Text("Return to Payment Options")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.green)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            
        }
        .padding()
    }
}

// Preview
struct PaymentFailureScreen_Previews: PreviewProvider {
    static var previews: some View {
        PaymentFailureScreen(
            onRetryPayment: {
                print("Retry Payment tapped")
            },
            onReturnToPaymentOptions: {
                print("Return to Payment Options tapped")
            }
        )
    }
}
