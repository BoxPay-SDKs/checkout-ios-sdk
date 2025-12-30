//
//  SavedCardKnowMore.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 18/07/25.
//

import SwiftUI


struct SavedCardKnowMore : View {
    var onGoBack: () -> Void
    var brandColor : String
    
    var body: some View {
        VStack(alignment:.leading,spacing: 0){
            Text("RBI Guidelines")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(Color(hex: "#2D2B32"))
            
            Text("As per the new RBI guidelines, we can no longer store your card information with us.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(Color(hex: "#2D2B32"))
                .padding(.top, 12)
            
            HStack(alignment: .top) {
                Image(frameworkAsset: "ic_card_lock")
                    .frame(width: 28, height: 28)
                
                Text("Your bank/card network will securely save your card information via tokenization if you consent for the same.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color(hex: "#4F4D55"))
                    .padding(.leading, 12)
            }
            .padding(.top, 28)
            
            HStack(alignment: .top) {
                Image(frameworkAsset: "ic_card_add")
                    .frame(width: 28, height: 28)
                
                Text("In case you choose to not tokenize, you’ll have to enter card details every time you pay.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(Color(hex: "#4F4D55"))
                    .padding(.leading, 12)
            }
            .padding(.top, 28)
            
            Button(action: {
                onGoBack()
            }){
                Text("Got it")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: brandColor))
                    .cornerRadius(8)
                    .font(.custom("Poppins-Regular", size: 16))
            }
            .padding(.top, 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }
}
