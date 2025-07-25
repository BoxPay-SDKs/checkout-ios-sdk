//
//  savedItemRow.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 17/07/25.
//

import SwiftUICore
import SwiftUI

struct SavedItemRow : View {
    var savedItem : CommonDataClass
    var fallbackImage : String
    var onClick : (_ selectedInstrumentValue : String) -> Void
    var selectedItemInstrumentValue : String
    var onProceedButton : (_ selectedInstrumentValue : String) -> Void
    var brandColor : String
    var currencySymbol : String
    var amount : String
    
    var body: some View {
        VStack(spacing: 0){
            HStack(alignment: .center) {
                SVGImageView(url: URL(string: savedItem.logoUrl)!, fallbackImage: fallbackImage)
                VStack(alignment: .leading) {
                    Text(savedItem.displayNumber)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "#4F4D55"))
                    
                    Text(savedItem.displayName)
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(selectedItemInstrumentValue == savedItem.instrumentTypeValue ? Color(hex: brandColor) : Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if selectedItemInstrumentValue == savedItem.instrumentTypeValue {
                        Circle()
                            .fill(Color(hex: brandColor))
                            .frame(width: 12, height: 12)
                    }
                }
                .onTapGesture {
                    onClick(savedItem.instrumentTypeValue)
                }
            }
            .onTapGesture {
                onClick(savedItem.instrumentTypeValue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            if selectedItemInstrumentValue == savedItem.instrumentTypeValue {
                Button(action: {
                    onProceedButton(selectedItemInstrumentValue)
                }) {
                    (
                        Text("Proceed to Pay ")
                            .font(.custom("Poppins-SemiBold", size: 16)) +
                        Text(currencySymbol)
                            .font(.custom("Inter-SemiBold", size: 16)) +
                        Text(amount)
                            .font(.custom("Poppins-SemiBold", size: 16))
                    )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: brandColor))
                        .cornerRadius(8)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: selectedItemInstrumentValue == savedItem.instrumentTypeValue)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(selectedItemInstrumentValue == savedItem.instrumentTypeValue ? Color(hex: "#EDF8F4") : Color.white)
    }
}
