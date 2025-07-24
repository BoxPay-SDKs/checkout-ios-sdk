//
//  PaymentOptionsView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI
import SwiftUICore

struct PaymentOptionView: View {
    @Binding var items : [CommonDataClass]
    var onProceed : (_ selectedInstrumentValue : String, _ selectedDisplayName : String, _ paymentType : String) -> Void
    var showLastUsed : Bool = false
    
    @ObservedObject private var viewModel : ItemsViewModel = ItemsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                PaymentOptionRow(
                    isSelected: viewModel.selectedInstrumentValue == item.instrumentTypeValue,
                    imageUrl: item.logoUrl,
                    title: item.displayName,
                    currencySymbol: viewModel.currencySymbol,
                    amount: viewModel.amount,
                    instrumentValue: item.instrumentTypeValue,
                    brandColor: viewModel.brandColor,
                    onClick: { newInstrumentValue, newDisplayName in
                        viewModel.onChangeInstrumentValue(newInstrumentValue: newInstrumentValue, newDisplayValue: newDisplayName, paymentType: item.type)
                    },
                    onProceedButton: {
                        onProceed(viewModel.selectedInstrumentValue , viewModel.selectedDisplayName, viewModel.selectedPaymentType)
                    },
                    fallbackImage: "ic_bnpl_semi_bold",
                    showLastUsed: showLastUsed ? items[0].instrumentTypeValue == item.instrumentTypeValue : false
                )
                if index < items.count - 1 {
                    Divider()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal, 16)
    }
}

struct PaymentOptionRow : View {
    var isSelected : Bool
    var imageUrl : String
    var title : String
    var currencySymbol : String
    var amount : String
    var instrumentValue : String
    var brandColor : String
    var onClick : (_ selectedInstrumentValue : String, _ selectedDisplayName : String) -> Void
    var onProceedButton : () -> Void
    var fallbackImage : String
    var showLastUsed : Bool = false
    
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                SVGImageView(url: URL(string: imageUrl)!, fallbackImage: fallbackImage)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                    if(showLastUsed) {
                        Text("Last Used")
                            .font(.custom("Poppins-Medium", size: 8))
                            .foregroundColor(Color(hex: "#1CA672"))
                            .padding(.bottom, 2)
                        .padding(.horizontal, 4)
                        .background(Color(hex: "#E8F6F1"))
                        .cornerRadius(6)
                        
                    }
                }
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: brandColor) : Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: brandColor))
                            .frame(width: 12, height: 12)
                    }
                }
                .onTapGesture {
                    onClick(instrumentValue , title)
                }
            }
            .onTapGesture {
                    onClick(instrumentValue , title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            // Pay Button
            if isSelected {
                Button(action: {
                    onProceedButton()
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
                .animation(.easeInOut, value: isSelected)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(isSelected ? Color(hex: "#EDF8F4") : Color.white)
    }
}
