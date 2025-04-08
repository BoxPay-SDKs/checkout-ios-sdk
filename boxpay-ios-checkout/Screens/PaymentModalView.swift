//
//  PaymentModalView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 17/03/25.
//


import SwiftUI

struct PaymentModalView: View {
    let price: String
    let selectedPaymentMethod: String
    var onPressOtherOptions: () -> Void
    var onProceedToPay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Payment Header
            HStack {
                
                VStack(alignment: .leading,spacing: 5){
                    Text("Payment ₹" + price)
                        .font(.system(size: 18, weight: .semibold))
                    
                    // Last Used Payment Option Label
                    Text("Last Used Payment Option")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
                
                
                Spacer()
                
                Button(action: {
                    // Handle other options action
                    onPressOtherOptions()
                }) {
                    Text("Other Options >")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.green)
                }
            }
            
            
            // Payment Option
            HStack {
                Image(frameworkAsset: "upi_logo") // Add upi logo asset
                    .resizable()
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                
                Text(selectedPaymentMethod)
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // Radio Button
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            // Proceed to Pay Button
            Button(action: {
                onProceedToPay()
                print("Proceed to Pay ₹" + price)
                // Handle payment action here
            }) {
                Text("Proceed to Pay ₹" + price)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.top, 1)
        }
        .padding(.horizontal) // Keep horizontal padding
        .padding(.top) // Keep top padding
        .background(Color.white)
        .cornerRadius(12)
        .padding(.bottom, 0) // Remove bottom padding
    }
}

struct PaymentModalView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentModalView(price: "36,770", selectedPaymentMethod: "test@boxpay", onPressOtherOptions: {
            print("Other options tapped")
        }, onProceedToPay: {
            print("Proceed to pay tapped")
        })
    }
}
