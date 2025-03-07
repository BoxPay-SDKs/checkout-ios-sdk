//
//  CustomDialogView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 07/03/25.
//


import SwiftUI

struct CustomDialogView: View {
    let title: String
    let message: String
    let option1: String
    let option2: String
    let onYes: () -> Void
    let onNo: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    
                
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            Divider().padding(.top, 15)
            
            Button(action: onYes) {
                Text(option1)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.top,17)
                    .padding(.bottom,17)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
            }.frame(maxWidth: .infinity)
            
            Divider()
            
            
            Button(action: onNo) {
                Text(option2)
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.black)
            }.frame(maxWidth: .infinity)
            
            
        }
        .padding(.top, 15)
        .padding(.bottom, 3)
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
