//
//  UpiTimerSheet.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI

struct UpiTimerSheet: View {
    var onCancelButton: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @Binding var _vpa: String
    var brandColor:String
    
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()

    @State private var timeRemaining: Int = 300 // 5 minutes = 300 seconds
    @State private var progress: CGFloat = 1.0

    // Timer setup
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_RESULT_SCREEN_DISPLAYED.rawValue, "UPIID Timer Screen Cancel Button Clicked", "")
                    onCancelButton()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "#000000").opacity(0.45))
                        .frame(width: 16, height: 16)
                }

                Text("Processing Payment")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(Color(hex: "#000000").opacity(0.85))
                    .padding(.leading, 12)

            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            Divider()
            Text("Open your UPI application and confirm the payment before the time expires")
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(Color(hex: "#2D2B32"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 32)

            HStack {
                Image(frameworkAsset: "upi_icon_grey")
                    .resizable()
                    .foregroundColor(Color(hex: "#2D2B32"))
                    .frame(width: 14, height: 14)

                Text("UPI Id : " + _vpa)
                    .font(.custom("Poppins-Regular", size: 12))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 18)
            .background(RoundedRectangle(cornerRadius: 42).stroke(Color(hex: "#BABABA"), lineWidth: 1))
            .padding(.top, 14)

            Text("Expires in")
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "#1D1C20"))
                .padding(.top, 26)
                .padding(.bottom, 12)

            ZStack {
                Circle()
                    .stroke(Color(hex: "#E7E7E7"), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color(hex: brandColor), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text(formattedTime())
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(Color(hex: brandColor))
            }
            .frame(width: 140, height: 140)
            HStack {
                Text("Note: Kindly avoid using the back button until the transaction process is complete")
                    .multilineTextAlignment(.center)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            Button(action: {
                analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_RESULT_SCREEN_DISPLAYED.rawValue, "UPIID Timer Screen Cancel Button Clicked", "")
                onCancelButton()
            }) {
                Text("Cancel Payment")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(Color(hex: brandColor))
                    .padding(.top, 16)
            }.padding(.bottom, 24)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = CGFloat(timeRemaining) / 300.0
            } else {
                analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_RESULT_SCREEN_DISPLAYED.rawValue, "UPIID Timer Timed Out", "")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func formattedTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
