//
//  SavedCardsComponent.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 17/07/25.
//

import SwiftUI

struct SavedCardsComponent : View {
    @Binding var savedItems : [CommonDataClass]
    var onProceedButton : (_ selectedInstrumentValue : String) -> Void
    var onClickAddNewCard : () -> Void
    
    @ObservedObject private var viewModel = ItemsViewModel()
        
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(savedItems.enumerated()), id: \.offset) { index, item in
                SavedItemRow(
                    savedItem : item,
                    fallbackImage:"ic_default_card",
                    onClick : { instrumentValue in
                        viewModel.onChangeInstrumentValue(newInstrumentValue: instrumentValue, newDisplayValue: "", paymentType: item.type)
                    },
                    selectedItemInstrumentValue: viewModel.selectedInstrumentValue,
                    onProceedButton: onProceedButton,
                    brandColor: viewModel.brandColor,
                    currencySymbol: viewModel.currencySymbol,
                    amount: viewModel.amount
                )
                Divider()
            }
            Button(action: {
                onClickAddNewCard()
            }) {
                HStack(alignment: .center) {
                    Image(frameworkAsset: "add_green", isTemplate: true)
                        .foregroundColor(Color(hex: viewModel.brandColor))
                        .frame(width:16, height:16)

                    VStack(alignment: .leading) {
                        Text("Add new Card")
                            .foregroundColor(Color(hex: viewModel.brandColor))
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal, 16)
    }
}
