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
    
    @State private var timeRemaining: Int = 300 // 5 minutes = 300 seconds
    @State private var progress: CGFloat = 1.0
    
    private let detector = UPIAppDetectorIOS()
    @State private var installedApps : [String] = []

    @State private var upiCollectVisible = false
    @State private var upiQRVisible = false
    @State private var upiCollectError = false
    @State private var upiCollectValid: Bool? = nil
    @State private var upiCollectTextInput = ""
    @State private var isQRChevronRotated = false
    @State private var isCollectChevronRotated = false
    @State private var isFocused = false
    @State private var selectedIntent: String? = nil
    
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()
    
    @State private var qrImage: UIImage?
    @State private var qrIsExpired = false
    
    @State private var timerCancellable: AnyCancellable?

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
                            intentButton(title: "GPay", imageName: "gpay_upi_logo", isSelected: selectedIntent == "GPay") {
                                selectedIntent = "GPay"
                                resetCollect()
                            }
                        }

                        if isPhonePeInstalled() {
                            intentButton(title: "PhonePe", imageName: "phonepe", isSelected: selectedIntent == "PhonePe") {
                                selectedIntent = "PhonePe"
                                resetCollect()
                            }
                        }

                        if isPaytmInstalled() {
                            intentButton(title: "PayTm", imageName: "paytm_upi_logo", isSelected: selectedIntent == "PayTm") {
                                selectedIntent = "PayTm"
                                resetCollect()
                            }
                        }

                    }
                    .padding(.top, isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled() ? 16 : 0)

                    if let intent = selectedIntent, !intent.isEmpty {
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
                if (isGooglePayInstalled() || isPhonePeInstalled() || isPaytmInstalled()) && !upiCollectVisible {
                    Divider()
                        .padding(.top, 12)
                }


                if isUpiCollectVisible {
                    VStack {
                        Button(action: toggleCollectSection) {
                            HStack {
                                Image(frameworkAsset: "add_green", isTemplate: true)
                                    .foregroundColor(Color(hex: viewModel.brandColor))
                                    .frame(width:16, height:16)
                                Text("Add new UPI Id")
                                    .foregroundColor(Color(hex: viewModel.brandColor))
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                Spacer()
                                Image(frameworkAsset: "chevron")
                                    .rotationEffect(.degrees(isCollectChevronRotated ? 0 : 180))
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom , isCollectChevronRotated ? 16 : 0)
                        }
                        .background(
                            Group {
                                if upiCollectVisible {
                                    Image(frameworkAsset: "add_upi_id_background")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Color.white
                                }
                            }
                        )

                        if upiCollectVisible {
                            VStack(alignment: .leading, spacing: 4) {
                                FloatingLabelTextField(
                                    placeholder: "Enter UPI ID",
                                    text: $upiCollectTextInput,
                                    isValid: $upiCollectValid,
                                    onChange: { newText in
                                        handleTextChange(newText)
                                    },
                                    isFocused: $isFocused,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )

                                if upiCollectError {
                                    Text("Please enter a valid UPI Id")
                                        .foregroundColor(Color(hex: "#E12121"))
                                        .font(.custom("Poppins-Regular", size: 12))
                                }

                                Button(action: {
                                    if let _ = upiCollectValid {
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "UPI Collect", "")
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "UPI Collect", "")
                                        analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "UPI Collect", "")
                                        handleUpiPayment(nil, upiCollectTextInput, nil, "upi")
                                    } else {
                                        upiCollectError = true
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
                                        .background(upiCollectValid == true ? Color(hex: viewModel.brandColor) : Color.gray.opacity(0.5))
                                        .cornerRadius(8)
                                        
                                }
                                .padding(.top, 12)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
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
                                    .rotationEffect(.degrees(isQRChevronRotated ? 0 : 180))
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom , isQRChevronRotated ? 16 : 0)
                        }
                        if upiQRVisible {
                            HStack {
                                if let qrImage = qrImage {
                                    Image(uiImage: qrImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 300, height: 300)
                                        .opacity(qrIsExpired ? 0.4 : 1.0)
                                }
                                VStack(alignment: .leading) {
                                    Text("Scan & Pay with UPI Application")
                                        .foregroundColor(Color(hex: "#2D2B32"))
                                        .font(.custom("Poppins-Medium", size: 12))
                                    Text("QR code will expire in \(timeRemaining)")
                                        .foregroundColor(Color(hex: "#2D2B32"))
                                        .font(.custom("Poppins-Medium", size: 12))
                                    Text(StringUtils.formattedTime(timeRemaining: $timeRemaining))
                                        .font(.custom("Poppins-SemiBold", size: 20))
                                        .foregroundColor(Color(hex: viewModel.brandColor))
                                }
                            }
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
                toggleQRSection()
                startTimer()
            }
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
    
    private func startTimer() {
        timerCancellable?.cancel() // Cancel any existing timer
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    progress = CGFloat(timeRemaining) / 300.0
                } else {
                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_RESULT_SCREEN_DISPLAYED.rawValue, "UPIQR Timer Timed Out", "")
                    qrIsExpired = true
                    timerCancellable?.cancel()
                }
            }
    }


    func toggleCollectSection() {
        selectedIntent = nil
        upiCollectVisible.toggle()
        upiQRVisible = false
        isQRChevronRotated = false
        isCollectChevronRotated.toggle()
    }
    
    func toggleQRSection() {
        selectedIntent = nil
        upiCollectVisible = false
        isQRChevronRotated.toggle()
        upiQRVisible.toggle()
        isCollectChevronRotated = false
    }

    func resetCollect() {
        upiCollectVisible = false
        upiQRVisible = false
        isQRChevronRotated = false
        isCollectChevronRotated = false
        upiCollectError = false
    }

    func handleTextChange(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let pattern = "^[a-zA-Z0-9.\\-_]{2,256}@[a-zA-Z]{3,64}$"
        let regex = try? NSRegularExpression(pattern: pattern)

        if let regex = regex, regex.firstMatch(in: trimmedText, options: [], range: NSRange(location: 0, length: trimmedText.utf16.count)) != nil {
            // ✅ Valid UPI
            upiCollectValid = true
            upiCollectError = false
        } else {
            // ❌ Invalid UPI
            if trimmedText.contains("@"), let suffix = trimmedText.split(separator: "@").last, suffix.count >= 2 {
                upiCollectError = true
                upiCollectValid = false
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
