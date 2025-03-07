//
//  CancelPaymentDialog.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 04/03/25.
//


import SwiftUI

struct CancelPaymentDialog: View {
    @Binding var isVisible: Bool
    var onCancel: () -> Void
    
    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.4) // Dim background
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isVisible = false // Dismiss on tap outside
                    }
                
                VStack(spacing: 16) {
                    Text("Are you sure you want to\ncancel payment?")
                        .font(.system(size: 18, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                    
                    Text("This payment request cancels only if\nyou haven't finished the payment")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    HStack {
                        Button(action: {
                            onCancel()
                            isVisible = false
                        }) {
                            Text("Yes, cancel")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        Button(action: {
                            isVisible = false
                        }) {
                            Text("No")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .frame(maxWidth: 300)
                .shadow(radius: 5)
            }
        }
    }
}
