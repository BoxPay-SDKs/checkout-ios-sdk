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
    @State private var countryFieldFrame: CGRect = .zero
    @State private var countryCodeFieldFrame: CGRect = .zero

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
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 20) {
                                // Full Name Field - stays in place
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
                            ).background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: CountryFieldBoundsPreferenceKey.self, value: geo.frame(in: .global))
                                }
                            )
                            .onPreferenceChange(CountryFieldBoundsPreferenceKey.self) { value in
                                DispatchQueue.main.async {
                                    countryFieldFrame = value
                                }
                            }
                                VStack(alignment: .leading) {
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
                                    if viewModel.isFullNameValid == false {
                                        Text(viewModel.fullNameErrorText)
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundColor(Color(hex: "#E12121"))
                                    }
                                }
                            VStack(alignment: .leading) {
                                FloatingLabelWithCodeTextField(
                                    placeholder: "Mobile Number*",
                                    countryCode: $viewModel.selectedCountryNumberCode,
                                    text: $viewModel.mobileNumberTextField,
                                    isValid: $viewModel.isMobileNumberValid,
                                    isFocused: $viewModel.isMobileNumberTextFieldFocused,
                                    isCodeFocused: $viewModel.isCountryCodeTextFieldFocused,
                                    onChangeText: { string in
                                        viewModel.onChangeMobileNumber(updatedText: string)
                                    },
                                    onChangeCode: { string in
                                        viewModel.onChangeCountryCodeTextField(updatedText: string)
                                    },
                                    keyboardType: .numberPad,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: CountryCodeFieldBoundsPreferenceKey.self, value: geo.frame(in: .global))
                                    }
                                )
                                .onPreferenceChange(CountryCodeFieldBoundsPreferenceKey.self) { value in
                                    DispatchQueue.main.async {
                                        countryCodeFieldFrame = value
                                    }
                                }
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
                        if viewModel.isCountryTextFieldFocused {
                                GeometryReader { geo in
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            if viewModel.countryNames.isEmpty {
                                                Text("No results found")
                                                    .foregroundColor(Color(hex: "#0A090B"))
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.white)
                                                    .font(.custom("Poppins-Regular", size: 16))
                                            } else {
                                                ForEach(viewModel.countryNames, id: \.self) { country in
                                                    Button(action: {
                                                        viewModel.onSelectCountryPicker(selectedCountry: country)
                                                    }) {
                                                        Text(country)
                                                            .foregroundColor(Color(hex: "#0A090B"))
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 12)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .background(Color.white)
                                                            .font(.custom("Poppins-Regular", size: 16))
                                                    }
                                                    Divider()
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .frame(maxHeight: 200)
                                    .position(x: geo.size.width / 2, y: 170) // Y offset to place below TextField
                                    .zIndex(1)
                                    .allowsHitTesting(false)
                                }
                            }
                        if viewModel.isCountryCodeTextFieldFocused {
                                GeometryReader { geo in
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            if viewModel.countryCodes.isEmpty {
                                                Text("No results found")
                                                    .foregroundColor(Color(hex: "#0A090B"))
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .background(Color.white)
                                                    .font(.custom("Poppins-Regular", size: 16))
                                            } else {
                                                ForEach(viewModel.countryCodes, id: \.self) { countryCode in
                                                    Button(action: {
                                                        viewModel.onSelectedCountryCodePicker(selectedCode: countryCode)
                                                    }) {
                                                        Text(countryCode)
                                                            .foregroundColor(Color(hex: "#0A090B"))
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 12)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .background(Color.white)
                                                            .font(.custom("Poppins-Regular", size: 16))
                                                    }
                                                    Divider()
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                    }
                                    .frame(maxHeight: 200)
//                                    .frame(width: 100)
                                    .position(x: geo.size.width / 2, y: 280) // Y offset to place below TextField
                                    .zIndex(1)
                                    .allowsHitTesting(false)
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    if viewModel.isAllDetailsValid() {
                        
                    }
                }){
                    Text("Save Address")
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

struct CountryFieldBoundsPreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct CountryCodeFieldBoundsPreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
