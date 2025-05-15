//
//  SelectTenureScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore
import SwiftUI

struct SelectTenureScreen : View {
    var selectedBank : Bank
    var selectedEmiMonth : Int? = nil
    @State var selectedEmiAmount : String? = nil
    var selectedInterestRate : String? = nil
    var itemsCount : Int
    var currencySymbol: String
    var totalAmount : String
    var brandColor : String
    var selectedCardType : String
    var fallBackImage : String
    @Binding var isSelectScreenVisible : Bool
    var onClickProceed : (EmiList) -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HeaderView(
                    text: "Select Tenure",
                    showDesc: true,
                    showSecure: false,
                    itemCount: itemsCount,
                    currencySymbol: currencySymbol,
                    amount: totalAmount,
                    onBackPress: {
                        isSelectScreenVisible.toggle()
                    }
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            SVGImageView(url: selectedBank.iconUrl, fallbackImage: fallBackImage)
                            Text("\(selectedBank.name) | \(selectedCardType)")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(Color(hex: "#2D2B32"))
                        }
                        .padding()
                        Divider()
                        ForEach(Array(selectedBank.emiList.enumerated()), id: \.1.amount) { index, item in
                            SelectTenureCardView(
                                duration: item.duration,
                                emiAmount: item.amount,
                                interestRate: item.percent,
                                interestRateAmount: item.interestCharged,
                                discountAmount: item.discount ?? "",
                                totalAmount: item.totalAmount,
                                gstAmount: item.processingFee,
                                debittedAmount: item.netAmount,
                                isSelectedRadio: Binding(
                                    get: { selectedEmiAmount == item.amount },
                                    set: { newValue in
                                        if newValue {
                                            selectedEmiAmount = item.amount
                                        }
                                    }
                                ),
                                brandColor: brandColor,
                                isNoCostApplied: item.noCostApplied,
                                isLowCostApplied: item.lowCostApplied,
                                currencySymbol: currencySymbol,
                                bankName: selectedBank.name,
                                onProceedForward: {
                                    onClickProceed(item)
                                },
                                onClickRadio: {
                                    selectedEmiAmount = item.amount
                                }
                            )

                            if index < selectedBank.emiList.count - 1 {
                                    Divider()// Remove extra padding around Divider
                                }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .background(Color(hex: "#F5F6FB"))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}


struct SelectTenureCardView: View {
    var duration: Int
    var emiAmount: String
    var interestRate: String
    var interestRateAmount: String
    var discountAmount: String
    var totalAmount: String
    var gstAmount: String
    var debittedAmount: String
    @Binding var isSelectedRadio: Bool
    var brandColor: String
    var isNoCostApplied: Bool
    var isLowCostApplied: Bool
    var currencySymbol: String
    var bankName : String

    var onProceedForward: () -> Void
    var onClickRadio: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(isSelectedRadio ? Color(hex: brandColor) : .gray, lineWidth: 2)
                        .frame(width: 16, height: 16)
                    if isSelectedRadio {
                        Circle()
                            .fill(Color(hex: brandColor))
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text("\(duration) months x ")
                            .font(.custom("Poppins-SemiBold", size: 14))
                        Text(currencySymbol)
                            .font(.custom("Inter-SemiBold", size: 14))
                        Text(emiAmount)
                            .font(.custom("Poppins-SemiBold", size: 14))
                        if !isSelectedRadio {
                            Text(" | @\(interestRate)% p.a.")
                                .font(.custom("Poppins-SemiBold", size: 14))
                        }
                    }
                    .foregroundColor(Color(hex: "#2D2B32"))
                    HStack {
                        if(isNoCostApplied) {
                            FilterTag(filterText: "NO COST EMI")
                        }
                        if(isLowCostApplied) {
                            FilterTag(filterText: "LOW COST EMI")
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .onTapGesture {
                onClickRadio()
            }

            // EMI Details
            if isSelectedRadio {
                VStack(spacing: 0) {
                    
                    // Header Row
                    HStack(spacing : 8) {
                        Text("Monthly EMI")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Interest @\(interestRate)% p.a.")
                            .frame(maxWidth: .infinity, alignment: .center)
                        if !discountAmount.isEmpty && discountAmount != "0" {
                            Text("Discount")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Text("Total Cost")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.leading, 8)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(Color(hex: "#2D2B32"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(Color(hex: "#F1F1F1"))
                    
                    
                    Rectangle()
                        .fill(Color(hex : "#E6E6E6"))
                        .frame(height: 1)


                    // Values Row
                    HStack(spacing: 8) {
                        (
                            Text(currencySymbol)
                                .font(.custom("Inter-Rgular", size: 12)) +
                            Text(emiAmount)
                                .font(.custom("Poppins-Medium", size: 12))
                        )
                        .foregroundColor(Color(hex: "#2D2B32"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        (
                            Text(currencySymbol)
                                .font(.custom("Inter-Rgular", size: 12)) +
                            Text(interestRateAmount)
                                .font(.custom("Poppins-Medium", size: 12))
                        )
                        .foregroundColor(Color(hex: "#2D2B32"))
                            .frame(maxWidth: .infinity, alignment: .center)
                        if !discountAmount.isEmpty && discountAmount != "0" {
                            (
                                Text("-\(currencySymbol)")
                                    .font(.custom("Inter-Rgular", size: 12))
                                    .foregroundColor(Color(hex: "#1CA672")) +
                                Text(discountAmount)
                                    .font(.custom("Poppins-Medium", size: 12))
                                    .foregroundColor(Color(hex: "#1CA672"))
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        (
                            Text(currencySymbol)
                                .font(.custom("Inter-Rgular", size: 12)) +
                            Text(totalAmount)
                                .font(.custom("Poppins-Medium", size: 12))
                        )
                        .foregroundColor(Color(hex: "#2D2B32"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.leading, 8)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(Color.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex : "#E6E6E6"), lineWidth: 1)
                )

                // Summary
                (
                    Text("Your card will be charged for an amount of ")
                        .font(.custom("Poppins-Regular", size: 12)) +
                    Text(currencySymbol)
                        .font(.custom("Inter-SemiBold", size: 12)) +
                    Text(debittedAmount)
                        .font(.custom("Poppins-SemiBold", size: 12)) +
                    Text(". You will be charged an interest of ")
                        .font(.custom("Poppins-Regular", size: 12)) +
                    Text(currencySymbol)
                        .font(.custom("Inter-SemiBold", size: 12)) +
                    Text(interestRateAmount)
                        .font(.custom("Poppins-SemiBold", size: 12)) +
                    Text(" by the bank making the total payable amount as ")
                        .font(.custom("Poppins-Regular", size: 12)) +
                    Text(currencySymbol)
                        .font(.custom("Inter-SemiBold", size: 12)) +
                    Text(totalAmount)
                        .font(.custom("Poppins-SemiBold", size: 12))
                )
                .foregroundColor(Color(hex: "#2D2B32"))
                
                (
                    Text(currencySymbol)
                        .font(.custom("Inter-SemiBold", size: 12)) +
                    Text(gstAmount)
                        .font(.custom("Poppins-SemiBold", size: 12)) +
                    Text("+GST will be charged by \(bankName) as one-time processing fee.")
                        .font(.custom("Poppins-Regular", size: 12))
                )
                .foregroundColor(Color(hex: "#2D2B32"))

                // Proceed Button
                Button(action: {
                    onProceedForward()
                }) {
                    Text("Proceed to Enter Card Details")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: brandColor))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(isSelectedRadio ? Color(hex:"#EFF3FA") : nil)
    }
}
