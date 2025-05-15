//
//  GeneralSuccessScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import Lottie

struct GeneralSuccessScreen: View {
    var transactionID: String
    var date: String
    var time: String
    var totalAmount: String
    var currencySymbol:String
    var onDone: (() -> Void)
    var brandColor:String

    var body: some View {
        VStack(spacing: 20) {
            // Success Icon
            LottieView(animation: .named("PaymentSuccessful"))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .frame(width: 80, height: 80)

            // Payment Success Text
            Text("Payment Successful!")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(Color(hex: "#019939"))

            // Details Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Transaction ID")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                    Spacer()
                    Text(transactionID)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                }

                HStack {
                    Text("Date")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                    Spacer()
                    Text(date)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                }

                HStack {
                    Text("Time")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                    Spacer()
                    Text(time)
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "#000000").opacity(0.85))
                }

            }
            .padding(.horizontal)

            DottedDivider()

            // Total Amount Section
            HStack {
                Text("Total Amount")
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(Color(hex: "#000000").opacity(0.85))
                Spacer()
                (
                    Text(currencySymbol)
                        .font(.custom("Inter-SemiBold", size: 16)) +
                    Text(totalAmount)
                        .font(.custom("Poppins-SemiBold", size: 16))
                )
                .foregroundColor(Color(hex: "#121212"))
            }
            .padding(.horizontal)

            DottedDivider()
            // Additional Info Text
            // Done Button
            Button(action: {
                onDone() // Execute the callback when "Done" is pressed
            }) {
                Text("Done")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: brandColor))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 5)
        }
        .padding(EdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16))
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct DottedDivider: View {
    var padding: CGFloat = 20 // Set padding value
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width - 2 * padding // Adjust width by removing padding from both sides
                let height: CGFloat = 1
                let spacing: CGFloat = 5 // Space between dots
                let dashLength: CGFloat = 4 // Length of each dot

                var x: CGFloat = padding // Start from the padding
                
                while x < width + padding {
                    path.move(to: CGPoint(x: x, y: height / 2))
                    path.addLine(to: CGPoint(x: x + dashLength, y: height / 2))
                    x += dashLength + spacing
                }
            }
            .stroke(Color.gray.opacity(0.6), lineWidth: 1) // Softer color
        }
        .frame(height: 1) // Controls the height of the line
    }
}
