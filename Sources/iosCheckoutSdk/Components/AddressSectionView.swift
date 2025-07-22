//
//  AddressSectionView.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/07/25.
//

import SwiftUI


struct AddressSectionView: View {
    @Binding var address: String
    @Binding var isShippingEnabled: Bool
    @Binding var isShippingEdiable : Bool
    @Binding var isFullNameEnabled: Bool
    @Binding var isFullNameEditable: Bool
    @Binding var isPhoneEnabled: Bool
    @Binding var isPhoneEditable: Bool
    @Binding var isEmailEnabled: Bool
    @Binding var isEmailEditable: Bool
    @Binding var fullNameText: String
    @Binding var phoneNumberText: String
    @Binding var emailIdText: String
    var brandColor: String
    @Binding var labelName : String

    var onClick: () -> Void

    var body: some View {
        if isEditableSectionAvailable {
            Button(action: onClick) {
                contentView
            }
        } else {
            contentView // show content without button interaction
        }
    }


    @ViewBuilder
    private var contentView: some View {
        if isShippingEnabled && address.isEmpty {
            addPromptView(text: "Add new address")
        } else if needsPersonalDetails {
            addPromptView(text: "Add personal details")
        } else {
            infoDisplayView
        }
    }
    
    private var isEditableSectionAvailable: Bool {
        (isShippingEnabled && isShippingEdiable) ||
        (isFullNameEnabled && isFullNameEditable) ||
        (isPhoneEnabled && isPhoneEditable) ||
        (isEmailEnabled && isEmailEditable)
    }

    private var needsPersonalDetails: Bool {
        (isEmailEnabled && emailIdText.isEmpty) ||
        (isPhoneEnabled && phoneNumberText.isEmpty) ||
        (isFullNameEnabled && fullNameText.isEmpty)
    }

    private func addPromptView(text: String) -> some View {
        HStack {
            Image(frameworkAsset: "add_green", isTemplate: true)
                .foregroundColor(Color(hex: brandColor))
                .frame(width:16, height:16)
            Text(text)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: brandColor))
            Spacer()
            Image(frameworkAsset: "chevron")
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(90))
        }
        .commonCardStyle()
    }

    private var infoDisplayView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(frameworkAsset: isShippingEnabled ? "map_pin_gray" : "ic_person")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
                    .scaledToFit()

                VStack(alignment: .leading, spacing: 0) {
                    infoHeaderView
                    infoSubTextView
                }

                Spacer()

                Image(frameworkAsset: "chevron")
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(90))
            }
            .commonCardStyle()
        }
    }

    @ViewBuilder
    private var infoHeaderView: some View {
        HStack {
            if isShippingEnabled {
                Text("Deliver at")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
                Text(labelName)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
            } else {
                if isFullNameEnabled {
                    Text(fullNameText)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if isFullNameEnabled && isPhoneEnabled {
                    Text("|")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if isPhoneEnabled {
                    Text(phoneNumberText)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
            }
        }
    }

    @ViewBuilder
    private var infoSubTextView: some View {
        if isShippingEnabled {
            Text(address)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if isEmailEnabled {
            Text(emailIdText)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
