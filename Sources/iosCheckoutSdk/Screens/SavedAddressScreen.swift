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
    @State private var navigateToAddressScreen = false


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
                    Button(action : {
                        navigateToAddressScreen = true
                    }) {
                        addPromptView(text: "Add new address", brandColor : viewModel.brandColor)
                    }
                    ScrollView{
                        TitleHeaderView(text: "Saved Addresses")
                            .padding(.bottom, 8)
                        if viewModel.savedAddressList.count == 0 {
                            VStack(alignment: .center, spacing: 16){
                                Image(frameworkAsset: "ic_search_not_found", isTemplate: false)
                                    .frame(width: 60, height: 60)
                                Text("Oops!! No results found")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                    .foregroundColor(Color(hex: "#212426"))
                                Text("Please try another search")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(Color(hex: "#4F4D55"))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300) // Set your desired limited height here
                            .frame(maxHeight: .infinity, alignment: .center)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal, 16)
                        } else {
                            ForEach(Array(viewModel.savedAddressList.enumerated()), id: \.element.addressRef) { index, address in
                                SavedAddressCard(
                                    addressDetails: address,
                                    selectedAddressRef: $viewModel.selectedAddressRef,
                                    brandColor: viewModel.brandColor,
                                    onClickAddress: { selected in
                                        viewModel.setSelectedAddressRef(addressRef: selected)
                                    },
                                    onClickOtherOptions: { selectedAddress in 
                                        print("other optrion clicked")
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal,16)
                }
                .background(Color(hex: "#F5F6FB"))
            }
            
            NavigationLink(destination: AddAddressScreen(), isActive: $navigateToAddressScreen) {
                        EmptyView()
                    }
        }
        .onAppear {
            viewModel.getSavedAddress()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onChange(of: viewModel.dataUpdationCompleted) { focused in
            if(focused) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
