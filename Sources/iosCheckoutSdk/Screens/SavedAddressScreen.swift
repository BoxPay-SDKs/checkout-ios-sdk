//
//  SavedAddressScreen.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 11/08/25.
//

import SwiftUI

struct SavedAddressScreen : View {
    @StateObject private var viewModel = SavedAddressViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            if viewModel.isFirstLoad {
                ShimmerPlaceholderScreen()
            } else if viewModel.isLoading {
                BoxpayLoaderView()
            } else {
                VStack(alignment: .leading) {
                    VStack {
                        HeaderView(
                            text: "Your Addresses",
                            showDesc: false,
                            showSecure: false,
                            itemCount: viewModel.itemsCount,
                            currencySymbol: viewModel.currencySymbol,
                            amount: viewModel.totalAmount,
                            onBackPress: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                    }
                    .background(Color.white)
                    addPromptView(text: "Add new address", brandColor : viewModel.brandColor)
                    ScrollView{
                        ForEach(Array(viewModel.savedAddressList.enumerated()), id: \.element.addressRef) { index, address in
                            SavedAddressCard(
                                addressDetails: address,
                                selectedAddressRef: $viewModel.selectedAddressRef,
                                brandColor: viewModel.brandColor,
                                onClickAddress: { selected in
                                    viewModel.setSelectedAddressRef(addressRef: selected)
                                },
                                onClickOtherOptions: {
                                    print("other optrion clicked")
                                }
                            )
                        }
                    }
                }
                .background(Color(hex: "#F5F6FB"))
            }
        }
        .onAppear {
            viewModel.getSavedAddress()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
