//
//  DccSuccessScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 20/03/25.
//

import SwiftUI

struct DccSuccessScreen: View {
    var transactionID: String
    var cardType: String
    var cardHolderName: String
    var total: String
    var exchangeRate: String
    var margin: String
    var transactionCurrency: String
    var paymentMethod: String
    var totalAmount: String
    var baseMoneyCurrency: String
    var dccCurrency: String
    var dspCode: String
    var isDccEnabled: Bool
    var date: String
    var time: String
    var amountpaymentViewModel: String
    var currencypaymentViewModel: String
    var onDone: (() -> Void)? = nil // Optional callback for "Done" button

    var body: some View {
        VStack(spacing: 20) {
            successIcon
            paymentSuccessText
            detailsSection
            DottedDivider()
            totalAmountSection
            DottedDivider()
            if(isDccEnabled){
                additionalInfoText
            }
            doneButton
        }
        .padding(EdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16))
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var successIcon: some View {
        Image(frameworkAsset: "green_success")
            .resizable()
            .frame(width: 100, height: 100)
            .foregroundColor(.green)
    }
    
    private var paymentSuccessText: some View {
        Text("Payment Successful!")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color.green)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if(isDccEnabled){
                detailRow(title: "Your merchant name", value: transactionID)
            }
            detailRow(title: "Transaction ID", value: transactionID)
            detailRow(title: "Date", value: date)
            detailRow(title: "Time", value: time)
            if(isDccEnabled){
                detailRow(title: "Card type", value: cardType)
                detailRow(title: "Cardholder name", value: cardHolderName)
                detailRow(title: "Transaction total \(baseMoneyCurrency)", value: "\(baseMoneyCurrency) \(total)")
                detailRow(title: "Exchange rate", value: "1 \(baseMoneyCurrency) = \(exchangeRate) \(transactionCurrency)")
                detailRow(title: "Margin", value: "\(margin)%")
                detailRow(title: "Transaction currency", value: transactionCurrency)
            }
        }
        .padding(.horizontal)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    private var totalAmountSection: some View {
        HStack {
            Text("Transaction Total Amount")
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            if(isDccEnabled){
                Text("\(transactionCurrency) \(totalAmount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }else{
                Text("\(currencypaymentViewModel) \(amountpaymentViewModel)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            
        }
        .padding(.horizontal)
    }
    
    private var additionalInfoText: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("I have been offered a choice of currencies and agree to pay in \(dccCurrency). This currency conversion service is provided by \(dspCode).")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
            
            Text("Please print and retain for your records.")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 11)
    }
    
    private var doneButton: some View {
        Button(action: {
            onDone?() // Execute the callback when "Done" is pressed
        }) {
            Text("Done")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
}



struct DccSuccessScreenSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        DccSuccessScreen(transactionID: "dhwi37hdw", cardType: "VISA", cardHolderName: "Ankush", total: "99", exchangeRate: "44.5", margin: "3.4", transactionCurrency: "INR", paymentMethod: "", totalAmount: "1045",baseMoneyCurrency:  "USD", dccCurrency: "INR", dspCode: "Fexco", isDccEnabled: false, date: "", time: "", amountpaymentViewModel : "", currencypaymentViewModel: "")
    }
}
