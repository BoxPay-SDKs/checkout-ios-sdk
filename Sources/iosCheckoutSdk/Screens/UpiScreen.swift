//
//  UpiScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import CrossPlatformSDK

struct UpiScreen: View {
    @Binding var isUpiIntentVisible: Bool
    var brandColor : String
    var totalAmount : String
    var currencySymbol : String
    @Binding var isUpiCollectVisible: Bool
    
    let handleUpiPayment: (_ selectedIntent: String?, _ shopperVpa: String?, _ methodType: String, _ selectedInstrumentRef : String?,_ selectedIntrumentRefType : String?) -> ()
    
    @Binding var savedUpiIds : [SavedItemDataClass]
    @Binding var selectedSavedUpiId : String
    let onClickSavedUpi : (_ selectedSavedUpiRef : String, _ selectedSavedUpiDisplayValue : String) -> ()
    let detector = UPIAppDetectorIOS()
    @State private var installedApps : [String] = []

    @State private var upiCollectVisible = false
    @State private var upiCollectError = false
    @State private var upiCollectValid: Bool? = nil
    @State private var upiCollectTextInput = ""
    @State private var isRotated = false
    @State private var isFocused = false
    @State private var selectedIntent: String? = nil

    var body: some View {
        VStack(alignment: .leading) {
            if (!savedUpiIds.isEmpty) {
                VStack(spacing : 0){
                    ForEach(Array(savedUpiIds.enumerated()), id: \.offset) { index, item in
                        PaymentOptionView(
                            isSelected: selectedSavedUpiId == item.instrumentTypeValue,
                            imageUrl: item.logoUrl,
                            title: item.displayNumber,
                            currencySymbol: currencySymbol,
                            amount: totalAmount,
                            instrumentValue: item.instrumentTypeValue,
                            brandColor: brandColor,
                            onClick: { string in
                                onClickSavedUpi(string, item.displayNumber)
                            },
                            onProceedButton: {
                                handleUpiPayment(nil,item.displayNumber, "UpiCollect", selectedSavedUpiId, "upi")
                            },
                            fallbackImage: "upi_logo"
                        )
                        Divider()
                    }
                }
            }
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
                        handleUpiPayment(selectedIntent,upiCollectTextInput, "UpiIntent", nil, "upi")
                    }) {
                        (
                            Text("Pay ")
                                .font(.custom("Poppins-SemiBold", size: 16)) +
                            Text(currencySymbol)
                                .font(.custom("Inter-SemiBold", size: 16)) +
                            Text("\(totalAmount) via \(intent)")
                                .font(.custom("Poppins-SemiBold", size: 16))
                        )
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: brandColor))
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
                                .foregroundColor(Color(hex: brandColor))
                                .frame(width:16, height:16)
                            Text("Add new UPI Id")
                                .foregroundColor(Color(hex: brandColor))
                                .font(.custom("Poppins-SemiBold", size: 14))
                            Spacer()
                            Image(frameworkAsset: "chevron")
                                .rotationEffect(.degrees(isRotated ? 0 : 180))
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom , isRotated ? 16 : 0)
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
                                    handleUpiPayment(selectedIntent, upiCollectTextInput, "UpiCollect", nil, "upi")
                                } else {
                                    upiCollectError = true
                                }
                            }){
                                (
                                    Text("Verify & Pay ")
                                        .font(.custom("Poppins-Regular", size: 16)) +
                                    Text(currencySymbol)
                                        .font(.custom("Inter-Regular", size: 16)) +
                                    Text(totalAmount)
                                        .font(.custom("Poppins-Regular", size: 16))
                                )
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(upiCollectValid == true ? Color(hex: brandColor) : Color.gray.opacity(0.5))
                                    .cornerRadius(8)
                                    
                            }
                            .padding(.top, 12)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.bottom, 16)
            }

        }
        .onAppear() {
            let upiService = UPIService(detector: detector)
            installedApps = upiService.getAvailableApps()
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
                        .stroke(isSelected ? Color(hex: brandColor) : Color.clear, lineWidth: 2)
                )
            }

            Text(title)
                .foregroundColor(isSelected ? Color(hex: brandColor) : .primary)
                .font(.custom(isSelected ? "Poppins-SemiBold" : "Poppins-Regular", size: 14))
        }
        .padding(.leading, 16)
    }


    func toggleCollectSection() {
        selectedIntent = nil
        upiCollectVisible.toggle()
        isRotated.toggle()
    }

    func resetCollect() {
        upiCollectVisible = false
        isRotated = false
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
