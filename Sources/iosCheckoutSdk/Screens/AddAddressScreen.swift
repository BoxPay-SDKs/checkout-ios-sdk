//
//  AddAddressScreen.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//

import SwiftUICore
import SwiftUI

struct AddAddressScreen : View {
    @StateObject private var viewModel = AddAddressViewModel()

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                HeaderView(
                    text: "Add Address",
                    showDesc: false,
                    showSecure: false,
                    itemCount: 0,
                    currencySymbol: "",
                    amount: "",
                    onBackPress: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                ScrollView {
                    VStack(spacing: 20) {
                        ZStack(alignment: .top) {
                                FloatingLabelTextField(
                                    placeholder: "Country*",
                                    text: $viewModel.countryTextField,
                                    isValid: .constant(nil),
                                    onChange: { string in
                                        viewModel.onChangeCountryTextField(updatedText: string)
                                    },
                                    isFocused: $viewModel.isCountryTextFieldFocused,
                                    trailingIcon: .constant("chevron"),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .zIndex(0) // keep the field below the dropdown
                                
                                // Only show the dropdown if the field is focused and there are results:
                                if viewModel.isCountryTextFieldFocused && !viewModel.countryNames.isEmpty {
                                    ScrollView(showsIndicators: true) {
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.countryNames, id: \.self) { country in
                                                Button(action: {
                                                    viewModel.onChangeCountryTextField(updatedText: country)
                                                }) {
                                                    Text(country)
                                                        .foregroundColor(.primary)
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 12)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .background(Color.white)
                                                }
                                                Divider() // optional: separator between rows
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 200)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                                    .offset(y: 56)
                                    .zIndex(1)
                                }
                            }
                        VStack(alignment: .leading){
                            FloatingLabelTextField(
                                placeholder: "Full Name*",
                                text: $viewModel.fullNameTextField,
                                isValid: $viewModel.isFullNameValid,
                                onChange: { string in
                                    viewModel.onChangeFullName(updatedText: string)
                                },
                                isFocused: $viewModel.isFullNameTextFieldFocused,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(viewModel.isFullNameValid == false) {
                                Text("\(viewModel.fullNameErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            FloatingLabelTextField(
                                placeholder: "Mobile Number*",
                                text: $viewModel.mobileNumberTextField,
                                isValid: $viewModel.isMobileNumberValid,
                                onChange: { string in
                                    viewModel.onChangeMobileNumber(updatedText: string)
                                },
                                isFocused: $viewModel.isMobileNumberTextFieldFocused,
                                keyboardType: .numberPad,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(viewModel.isMobileNumberValid == false) {
                                Text("\(viewModel.mobileNumberErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            FloatingLabelTextField(
                                placeholder: "Email ID*",
                                text: $viewModel.emailIdTextField,
                                isValid: $viewModel.isEmailIdValid,
                                onChange: { string in
                                    viewModel.onChangeEmailId(updatedText: string)
                                },
                                isFocused: $viewModel.isEmailIdTextFieldFocused,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(viewModel.isEmailIdValid == false) {
                                Text("\(viewModel.emailIdErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        
                        HStack(alignment : .top , spacing: 10){
                            VStack(alignment: .leading){
                                FloatingLabelTextField(
                                    placeholder: "ZIP/Postal Code*",
                                    text: $viewModel.postalCodeTextField,
                                    isValid: $viewModel.isPostalCodeValid,
                                    onChange: { string in
                                        viewModel.onChangePostalCode(updatedText: string)
                                    },
                                    isFocused: $viewModel.isPostalCodeTextFieldFocused,
                                    keyboardType: .numberPad,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                if(viewModel.isPostalCodeValid == false) {
                                    Text("\(viewModel.postalCodeErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                FloatingLabelTextField(
                                    placeholder: "City*",
                                    text: $viewModel.cityTextField,
                                    isValid: $viewModel.isCityValid,
                                    onChange: { string in
                                        viewModel.onChangeCity(updatedText: string)
                                    },
                                    isFocused: $viewModel.isCityTextFieldFocused,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                if(viewModel.isCityValid == false) {
                                    Text("\(viewModel.cityErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            FloatingLabelTextField(
                                placeholder: "State*",
                                text: $viewModel.stateTextField,
                                isValid: $viewModel.isStateValid,
                                onChange: { string in
                                    viewModel.onChangeState(updatedText: string)
                                },
                                isFocused: $viewModel.isStateTextFieldFocused,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(viewModel.isStateValid == false) {
                                Text("\(viewModel.stateErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            FloatingLabelTextField(
                                placeholder: "House number, Apartment*",
                                text: $viewModel.mainAddressTextField,
                                isValid: $viewModel.isMainAddressValid,
                                onChange: { string in
                                    viewModel.onChangeMainAddress(updatedText: string)
                                },
                                isFocused: $viewModel.isMainAddressTextFieldFocused,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(viewModel.isMainAddressValid == false) {
                                Text("\(viewModel.mainAddressErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        
                        FloatingLabelTextField(
                            placeholder: "Area,Colony,Street, Sector",
                            text: $viewModel.secondaryAddressTextField,
                            isValid: .constant(nil),
                            isFocused: $viewModel.isSecondaryAddressTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    if viewModel.isAllDetailsValid() {
                        
                    }
                }){
                    Text("Make Payment")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: viewModel.brandColor))
                        .cornerRadius(8)
                        .font(.custom("Poppins-Regular", size: 16))
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
