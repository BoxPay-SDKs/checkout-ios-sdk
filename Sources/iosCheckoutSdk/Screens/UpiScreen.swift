//
//  UpiScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import CrossPlatformSDK
import Combine

struct UpiScreen: View {
    let handleUpiPayment: (_ selectedIntent: String?, _ shopperVpa: String?, _ selectedInstrumentRef : String?,_ selectedIntrumentRefType : String?) -> ()
    let handleQRPayment : () -> ()
    @Binding var savedUpiIds : [CommonDataClass]
    @ObservedObject var viewModel : UpiViewModel
    @Binding var isUpiIntentVisible: Bool
    @Binding var isUpiCollectVisible: Bool
    @Binding var isUPIQRVisible : Bool
    @Binding var qrUrl : String
    
    private let detector = UPIAppDetectorIOS()
    @State private var installedApps : [String] = []
    
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()
    
    @State private var qrImage: UIImage?

    var body: some View {
        VStack{
            if (!savedUpiIds.isEmpty) {
                PaymentOptionView(
                    items: .constant(Array(savedUpiIds.prefix(2))),
                    onProceed: { instrumentValue, displayName, paymentType in
                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "SavedUPI", "")
                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "SavedUPI", "")
                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "SavedUPI", "")
                        handleUpiPayment(nil, displayName, instrumentValue, paymentType)
                    },
                    showLastUsed: false
                )
            }
            VStack(alignment: .leading) {
                if isUpiIntentVisible {
                    HStack {
                        if isGooglePayInstalled() {
                            intentButton(title: "GPay", imageName: "gpay_upi_logo", isSelected: viewModel.selectedIntent == "GPay") {
                                viewModel.selectedIntent = "GPay"
                                viewModel.resetCollect()
                            }
                        }

                        if isPhonePeInstalled() {
                            intentButton(title: "PhonePe", imageName: "phonepe", isSelected: viewModel.selectedIntent == "PhonePe") {
                                viewModel.selectedIntent = "PhonePe"
                                viewModel.resetCollect()
                            }
                        }

                        if isPaytmInstalled() {
                            intentButton(title: "PayTm", imageName: "paytm_upi_logo", isSelected: viewModel.selectedIntent == "PayTm") {
                                viewModel.selectedIntent = "PayTm"
                                viewModel.resetCollect()
                            }
                        }

                    }
                    .padding(.top, isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled() ? 16 : 0)

                    if let intent = viewModel.selectedIntent, !intent.isEmpty {
                        Button(action: {
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "UPI Intent \(intent)", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "UPI Intent \(intent)", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "UPI Intent \(intent)", "")
                            handleUpiPayment(intent,nil, nil, "upi")
                        }) {
                            (
                                Text("Pay ")
                                    .font(.custom("Poppins-SemiBold", size: 16)) +
                                Text(viewModel.currencySymbol)
                                    .font(.custom("Inter-SemiBold", size: 16)) +
                                Text("\(viewModel.amount) via \(intent)")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                            )
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: viewModel.brandColor))
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                    }
                }

                // 👇 Insert the divider here
                if (isGooglePayInstalled() || isPhonePeInstalled() || isPaytmInstalled()) && !viewModel.upiCollectVisible {
                    Divider()
                        .padding(.top, 12)
                }


                if isUpiCollectVisible {
                    VStack {
                        Button(action: viewModel.toggleCollectSection) {
                            HStack {
                                Image(frameworkAsset: "add_green", isTemplate: true)
                                    .foregroundColor(Color(hex: viewModel.brandColor))
                                    .frame(width:16, height:16)
                                Text("Add new UPI Id")
                                    .foregroundColor(Color(hex: viewModel.brandColor))
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                Spacer()
                                Image(frameworkAsset: "chevron")
                                    .rotationEffect(.degrees(viewModel.isCollectChevronRotated ? 0 : 180))
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom , viewModel.isCollectChevronRotated ? 16 : 0)
                        }
                        .background(
                            Group {
                                if viewModel.upiCollectVisible {
                                    Image(frameworkAsset: "add_upi_id_background")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Color.white
                                }
                            }
                        )

                        if viewModel.upiCollectVisible {
                            VStack(alignment: .leading, spacing: 4) {
                                FloatingLabelTextField(
                                    placeholder: "Enter UPI ID",
                                    text: $viewModel.upiCollectTextInput,
                                    isValid: $viewModel.upiCollectValid,
                                    onChange: { newText in
                                        handleTextChange(newText)
                                    },
                                    isFocused: $viewModel.isFocused,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )

                                if viewModel.upiCollectError {
                                    Text("Please enter a valid UPI Id")
                                        .foregroundColor(Color(hex: "#E12121"))
                                        .font(.custom("Poppins-Regular", size: 12))
                                }

                                Button(action: {
                                    if let _ = viewModel.upiCollectValid {
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "UPI Collect", "")
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "UPI Collect", "")
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "UPI Collect", "")
                                        handleUpiPayment(nil, viewModel.upiCollectTextInput, nil, "upi")
                                    } else {
                                        viewModel.upiCollectError = true
                                    }
                                }){
                                    (
                                        Text("Verify & Pay ")
                                            .font(.custom("Poppins-Regular", size: 16)) +
                                        Text(viewModel.currencySymbol)
                                            .font(.custom("Inter-Regular", size: 16)) +
                                        Text(viewModel.amount)
                                            .font(.custom("Poppins-Regular", size: 16))
                                    )
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(viewModel.upiCollectValid == true ? Color(hex: viewModel.brandColor) : Color.gray.opacity(0.5))
                                        .cornerRadius(8)
                                        
                                }
                                .padding(.top, 12)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.bottom, 8)
                }
                
                if isUpiCollectVisible && isUPIQRVisible && !UIDevice.current.name.contains("iPhone") {
                    Divider()
                }
                
                if isUPIQRVisible && !UIDevice.current.name.contains("iPhone") {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: handleQRPayment) {
                            HStack {
                                Image(frameworkAsset: "qr_code",isTemplate : true)
                                    .frame(width: 16, height: 15)
                                    .foregroundColor(Color(hex: "black"))
                                Text("Pay Using QR")
                                    .foregroundColor(Color(hex: viewModel.brandColor))
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                Spacer()
                                Image(frameworkAsset: "chevron")
                                    .rotationEffect(.degrees(viewModel.isQRChevronRotated ? 0 : 180))
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        }
                        if viewModel.upiQRVisible {
                            HStack(alignment: .center, spacing: 0) {
                                if let qrImage = qrImage {
                                    ZStack {
                                        Image(uiImage: qrImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .opacity(viewModel.qrIsExpired ? 0.2 : 1.0)
                                        
                                        // Blur overlay when expired
                                        if viewModel.qrIsExpired {
                                            Button(action: handleQRPayment) {
                                                HStack {
                                                    Image(systemName: "arrow.clockwise")
                                                    Text("Retry")
                                                        .foregroundColor(Color(hex: viewModel.brandColor))
                                                        .font(.custom("Poppins-SemiBold", size: 20))
                                                }
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 12)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text("Scan & Pay with UPI Application")
                                        .foregroundColor(Color(hex: "#2D2B32"))
                                        .font(.custom("Poppins-Medium", size: 12))
                                    Text("QR code will expire in")
                                        .foregroundColor(Color(hex: "#2D2B32"))
                                        .font(.custom("Poppins-Medium", size: 12))
                                    Text(StringUtils.formattedTime(timeRemaining: $viewModel.timeRemaining))
                                        .font(.custom("Poppins-SemiBold", size: 20))
                                        .foregroundColor(Color(hex: viewModel.brandColor))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear() {
            let upiService = UPIService(detector: detector)
            installedApps = upiService.getAvailableApps()
        }
        .onChange(of: qrUrl) { url in
            if !url.isEmpty {
                guard let data = Data(base64Encoded: url) else {
                    return
                }
                qrImage = UIImage(data: data)
                viewModel.toggleQRSection()
                viewModel.startTimer()
            }
        }
        .onDisappear {
            viewModel.timerCancellable?.cancel()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal, 16)
    }

    func intentButton(title: String, imageName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) { // spacing instead of .padding(.top)
            Button(action: action) {
                ZStack {
                    // Always reserve the same space
                    Circle()
                        .fill(Color.clear) // invisible background to ensure size
                        .frame(width: 44, height: 44) // total size always constant

                    Image(frameworkAsset: imageName)
                        .resizable()
                        .frame(width: isSelected ? 36 : 40, height: isSelected ? 36 : 40)
                        .padding(isSelected ? 4 : 0)
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color(hex: viewModel.brandColor) : Color.clear, lineWidth: 2)
                )
            }

            Text(title)
                .foregroundColor(isSelected ? Color(hex: viewModel.brandColor) : .primary)
                .font(.custom(isSelected ? "Poppins-SemiBold" : "Poppins-Regular", size: 14))
        }
        .padding(.leading, 16)
    }

    func handleTextChange(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let pattern = "^[a-zA-Z0-9.\\-_]{2,256}@[a-zA-Z]{3,64}$"
        let regex = try? NSRegularExpression(pattern: pattern)

        if let regex = regex, regex.firstMatch(in: trimmedText, options: [], range: NSRange(location: 0, length: trimmedText.utf16.count)) != nil {
            // ✅ Valid UPI
            viewModel.upiCollectValid = true
            viewModel.upiCollectError = false
        } else {
            // ❌ Invalid UPI
            if trimmedText.contains("@"), let suffix = trimmedText.split(separator: "@").last, suffix.count >= 2 {
                viewModel.upiCollectError = true
                viewModel.upiCollectValid = false
            }
        }
    }

    private func isGooglePayInstalled() -> Bool {
        return installedApps.contains("tez") || installedApps.contains("gpay")
    }

    // Check if Paytm is installed
    private func isPaytmInstalled() -> Bool {
        return installedApps.contains("paytm")
    }

    // Check if PhonePe is installed
    private func isPhonePeInstalled() -> Bool {
        return installedApps.contains("phonepe")
    }
}
