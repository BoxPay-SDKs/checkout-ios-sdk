//
//  RBIGuidelines.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 20/02/25.
//

import SwiftUI

struct RBIGuidelinesView: View {
    var onGoBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Align everything to the left
            HStack {
                Text("RBI Guidelines")
                    .font(.headline)
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal)
            
            Text("As per the new RBI guidelines, we can no longer store your card information with us.")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true) // Prevent truncation
                .padding(.horizontal)
            
            // Generic CVV Info
            HStack(alignment: .top, spacing: 15) {
                Image(frameworkAsset: "card_lock")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .overlay(Text("***").font(.title2).foregroundColor(.white))
                
                Text("Your bank/card network will securely save your card information via tokenization if you consent for the same.")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            Divider()
            
            // American Express CVV Info
            HStack(alignment: .top, spacing: 15) {
                Image(frameworkAsset: "card_add")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .overlay(Text("****").font(.title2).foregroundColor(.white))
                
                Text("In case you choose to not tokenize, you’ll have to enter card details every time you pay.")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            Button(action: {
                onGoBack()
            }) {
                Text("Got It!")
                    .frame(maxWidth: .infinity, alignment: .center) // Keep button centered
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
}



struct RBIGuidelinesView_Previews: PreviewProvider {
    static var previews: some View {
        RBIGuidelinesView(onGoBack: {
            print("Go back tapped(RBI guidelines view)")
        })
    }
}
