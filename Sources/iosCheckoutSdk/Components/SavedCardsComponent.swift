//
//  SavedCardsComponent.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 17/07/25.
//

import SwiftUICore
import SwiftUI

struct SavedCardsComponent : View {
    @Binding var selectedItemInstrumentValue : String
    @Binding var isContainerExpanded : Bool
    var savedItems : [SavedItemDataClass] = []
    var onClickRadioButton : ((String) -> Void)? = nil
    var onProceedButton : () -> Void = {}
    var brandColor : String = ""
    var currencySymbol : String = ""
    var totalAmount : String = ""
    var onClickAddNewCard : () -> Void
    
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(savedItems.enumerated()), id: \.offset) { index, item in
                SavedItemRow(
                    savedItem : item,
                    fallbackImage:"ic_default_card",
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
            Button(action: {
                onClickAddNewCard()
            }) {
                HStack(alignment: .center) {
                    Image(frameworkAsset: "add_green", isTemplate: true)
                        .foregroundColor(Color(hex: brandColor))
                        .frame(width:16, height:16)

                    VStack(alignment: .leading) {
                        Text("Add new Card")
                            .foregroundColor(Color(hex: brandColor))
                            .font(.custom("Poppins-SemiBold", size: 14))
                    }

                    Spacer()

                    Image(frameworkAsset: "chevron")
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(90))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}
