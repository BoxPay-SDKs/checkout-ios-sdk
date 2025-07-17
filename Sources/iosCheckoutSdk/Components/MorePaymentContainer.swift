//
//  MorePaymentContainer.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUICore
import SwiftUI

struct MorePaymentContainer : View {
    let handleButtonClick : () -> ()
    var image : String
    var title : String
    @Binding var selectedItemInstrumentValue : String
    @Binding var isContainerExpanded : Bool
    var savedItems : [SavedItemDataClass] = []
    var onClickRadioButton : ((String) -> Void)? = nil
    var onProceedButton : () -> Void = {}
    var brandColor : String = ""
    var currencySymbol : String = ""
    var totalAmount : String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                handleButtonClick()
            }) {
                HStack(alignment: .center) {
                    Image(frameworkAsset: image)
                        .frame(width: 32, height: 32) // Consistent icon size

                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(Color(hex: "#363840"))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(frameworkAsset: "chevron")
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(90))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            if(!savedItems.isEmpty && isContainerExpanded) {
                ForEach(Array(savedItems.enumerated()), id: \.offset) { index, item in
                    SavedItemRow(
                        savedItem : item,
                        fallbackImage:"",
                        onClick : { string in
                            onClickRadioButton!(string)
                        },
                        selectedItemInstrumentValue: selectedItemInstrumentValue,
                        onProceedButton: onProceedButton,
                        brandColor: brandColor,
                        currencySymbol: currencySymbol,
                        amount: totalAmount
                    )
                    Divider()
                }
            }
        }
    }
}
