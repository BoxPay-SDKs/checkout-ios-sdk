//
//  AddAddressScreen.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//

import SwiftUICore
import SwiftUI
import CountryPickerView

struct AddAddressScreen : View {
    @Binding var isCheckoutFocused : Bool
    @State private var cpv = CountryPickerView()
    @StateObject private var viewModel = AddAddressViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State private var countryPickerCoordinator: CountryPickerCoordinator? // Keep a reference

    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                HeaderView(
                    text: viewModel.isShippingEnabled ? "Add Address" : "Add Personal Details",
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
                            if(viewModel.isShippingEnabled) {
                                FloatingLabelTextField(
                                    placeholder: "Country*",
                                    text: $viewModel.countryTextField,
                                    isValid: .constant(nil),
                                    onChange: nil,
                                    isFocused: $viewModel.isCountryTextFieldFocused,
                                    trailingIcon: .constant("chevron"),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                            }
                            if(viewModel.isFullNameEnabled) {
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
                            }
                            if(viewModel.isMobileNumberEnabled) {
                                VStack(alignment: .leading) {
                                    FloatingLabelWithCodeTextField(
                                        placeholder: "Mobile Number*",
                                        countryCode: $viewModel.selectedCountryNumberCode,
                                        text: $viewModel.mobileNumberTextField,
                                        isValid: $viewModel.isMobileNumberValid,
                                        isFocused: $viewModel.isMobileNumberTextFieldFocused,
                                        onChangeCode: { newCode, newName, newPhoneCode  in
                                            viewModel.onChangeCountryCodeTextField(newCountryCode: newCode, newName: newName, newPhoneCode: newPhoneCode)
                                        }
                                    )
                                    if(viewModel.isMobileNumberValid == false) {
                                        Text("\(viewModel.mobileNumberErrorText)")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundColor(Color(hex: "#E12121"))
                                    }
                                }
                            }
                            
                            if(viewModel.isEmailIdEnabled) {
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
                            }
                            
                            if(viewModel.isShippingEnabled) {
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
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    Task {
                        let result = await viewModel.isAllDetailsValid()
                        if result {
                            viewModel.updateUserData()
                        }
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
        .onChange(of: viewModel.dataUpdationCompleted) { focused in
            if(focused) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: viewModel.isCountryTextFieldFocused) { focused in
            if(focused) {
                showPicker()
            }
        }
    }
    
    private func showPicker() {
        countryPickerCoordinator = CountryPickerCoordinator { country in  //assigning value to state variable
            viewModel.countryTextField = country.name
            viewModel.selectedCountryCode = country.code
            viewModel.isCountryTextFieldFocused = false
        }
        if let rootVC = topViewController() {
            cpv.delegate = countryPickerCoordinator
            cpv.showCountriesList(from: rootVC)
        }
    }
    
    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

class CountryPickerCoordinator: NSObject, CountryPickerViewDelegate {
    var onSelect: (Country) -> Void
    
    init(onSelect: @escaping (Country) -> Void) {
        self.onSelect = onSelect
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        onSelect(country)
    }
}
