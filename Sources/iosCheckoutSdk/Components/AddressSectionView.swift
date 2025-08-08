//
//  AddressSectionView.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/07/25.
//

import SwiftUI


struct AddressSectionView: View {
    var onClick: () -> Void
    
    @ObservedObject private var viewModel = AddAddressViewModel()

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
        if viewModel.isShippingEnabled && viewModel.address.isEmpty {
            addPromptView(text: "Add new address")
        } else if needsPersonalDetails {
            addPromptView(text: "Add personal details")
        } else {
            infoDisplayView
        }
    }
    
    private var isEditableSectionAvailable: Bool {
        (viewModel.isShippingEnabled && viewModel.isShippingEditable) ||
        (viewModel.isFullNameEnabled && viewModel.isFullNameEditable) ||
        (viewModel.isMobileNumberEnabled && viewModel.isMobileNumberEditable) ||
        (viewModel.isEmailIdEnabled && viewModel.isEmailIdEditable)
    }

    private var needsPersonalDetails: Bool {
        (viewModel.isEmailIdEnabled && viewModel.emailIdTextField.isEmpty) ||
        (viewModel.isMobileNumberEnabled && viewModel.mobileNumberTextField.isEmpty) ||
        (viewModel.isFullNameEnabled && viewModel.fullNameTextField.isEmpty)
    }

    private func addPromptView(text: String) -> some View {
        HStack {
            Image(frameworkAsset: "add_green", isTemplate: true)
                .foregroundColor(Color(hex: viewModel.brandColor))
                .frame(width:16, height:16)
            Text(text)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: viewModel.brandColor))
            Spacer()
            Image(frameworkAsset: "chevron")
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(90))
        }
        .padding(12)
        .commonCardStyle()
    }

    private var infoDisplayView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(frameworkAsset: viewModel.isShippingEnabled ? "map_pin_gray" : "ic_person")
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
            .padding(12)
            .commonCardStyle()
        }
    }

    @ViewBuilder
    private var infoHeaderView: some View {
        HStack {
            if viewModel.isShippingEnabled {
                Text("Deliver at")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
                Text(viewModel.addressLabelName)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
            } else {
                if viewModel.isFullNameEnabled {
                    Text(viewModel.fullNameTextField)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if viewModel.isFullNameEnabled && viewModel.isMobileNumberEnabled {
                    Text("|")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if viewModel.isMobileNumberEnabled {
                    Text(viewModel.mobileNumberTextField)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
            }
        }
    }

    @ViewBuilder
    private var infoSubTextView: some View {
        if viewModel.isShippingEnabled {
            Text(viewModel.address)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if viewModel.isEmailIdEnabled {
            Text(viewModel.emailIdTextField)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
