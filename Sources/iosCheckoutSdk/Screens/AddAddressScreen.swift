//
//  AddAddressScreen.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//

import SwiftUICore
import SwiftUI

struct AddAddressScreen : View {
    let emailRegex = "^(?!.*\\.\\.)(?!.*\\.\\@)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    let numberRegex = "^[0-9]+$"
    
    @State private var fullNameTextField = ""
    @State private var mobileNumberTextField = ""
    @State private var mobileNumberMinLength = 0
    @State private var mobileNumberMaxLength = 0
    @State private var emailIdTextField = ""
    @State private var postalCodeTextField = ""
    @State private var postalCodeMaxLength = 0
    @State private var cityTextField = ""
    @State private var stateTextField = ""
    @State private var mainAddressTextField = ""
    @State private var secondaryAddressTextField = ""
    @State private var selectedCountryName = ""
    @State private var selectedCountryCode = ""
    
    @State private var isFullNameTextFieldFocused = false
    @State private var isMobileNumberTextFieldFocused = false
    @State private var isEmailIdTextFieldFocused = false
    @State private var isPostalCodeTextFieldFocused = false
    @State private var isCityTextFieldFocused = false
    @State private var isStateTextFieldFocused = false
    @State private var isMainAddressTextFieldFocused = false
    @State private var isSecondaryAddressTextFieldFocused = false
    
    @State private var isFullNameValid : Bool? = nil
    @State private var isMobileNumberValid : Bool? = nil
    @State private var isEmailIdValid : Bool? = nil
    @State private var isPostalCodeValid : Bool? = nil
    @State private var isCityValid : Bool? = nil
    @State private var isStateValid : Bool? = nil
    @State private var isMainAddressValid : Bool? = nil
    
    @State private var fullNameErrorText = ""
    @State private var mobileNumberErrorText = ""
    @State private var emailIdErrorText = ""
    @State private var postalCodeErrorText = ""
    @State private var cityErrorText = ""
    @State private var stateErrorText = ""
    @State private var mainAddressErrorText = ""
    
    var brandColor : String
     
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
                        FloatingLabelTextField(
                            placeholder: "Full Name*",
                            text: $fullNameTextField,
                            isValid: $isFullNameValid,
                            onChange: { string in
                                onChangeFullName(updatedText: string)
                            },
                            isFocused: $isFullNameTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                        if(isFullNameValid == false) {
                            Text("\(fullNameErrorText)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#E12121"))
                        }
                        
                        FloatingLabelTextField(
                            placeholder: "Mobile Number*",
                            text: $mobileNumberTextField,
                            isValid: $isMobileNumberValid,
                            onChange: { string in
                                onChangeMobileNumber(updatedText: string)
                            },
                            isFocused: $isMobileNumberTextFieldFocused,
                            keyboardType: .numberPad,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                        if(isMobileNumberValid == false) {
                            Text("\(mobileNumberErrorText)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#E12121"))
                        }
                        
                        FloatingLabelTextField(
                            placeholder: "Email ID*",
                            text: $emailIdTextField,
                            isValid: $isEmailIdValid,
                            onChange: { string in
                                onChangeEmailId(updatedText: string)
                            },
                            isFocused: $isEmailIdTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                        if(isEmailIdValid == false) {
                            Text("\(emailIdErrorText)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#E12121"))
                        }
                        
                        HStack(spacing: 10){
                            VStack(alignment: .leading){
                                FloatingLabelTextField(
                                    placeholder: "ZIP/Postal Code*",
                                    text: $postalCodeTextField,
                                    isValid: $isPostalCodeValid,
                                    onChange: { string in
                                        onChangePostalCode(updatedText: string)
                                    },
                                    isFocused: $isPostalCodeTextFieldFocused,
                                    keyboardType: .numberPad,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                
                                if(isPostalCodeValid == false) {
                                    Text("\(postalCodeErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                            VStack(alignment: .leading) {
                                FloatingLabelTextField(
                                    placeholder: "City*",
                                    text: $cityTextField,
                                    isValid: $isCityValid,
                                    onChange: { string in
                                        onChangeCity(updatedText: string)
                                    },
                                    isFocused: $isCityTextFieldFocused,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                
                                if(isCityValid == false) {
                                    Text("\(cityErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                        }
                        FloatingLabelTextField(
                            placeholder: "State*",
                            text: $stateTextField,
                            isValid: $isStateValid,
                            onChange: { string in
                                onChangeState(updatedText: string)
                            },
                            isFocused: $isStateTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                        if(isStateValid == false) {
                            Text("\(stateErrorText)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#E12121"))
                        }
                        
                        FloatingLabelTextField(
                            placeholder: "House number, Apartment*",
                            text: $mainAddressTextField,
                            isValid: $isMainAddressValid,
                            onChange: { string in
                                onChangeMainAddress(updatedText: string)
                            },
                            isFocused: $isMainAddressTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                        if(isMainAddressValid == false) {
                            Text("\(mainAddressErrorText)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color(hex: "#E12121"))
                        }
                        
                        FloatingLabelTextField(
                            placeholder: "Area,Colony,Street, Sector",
                            text: $secondaryAddressTextField,
                            isValid: .constant(nil),
                            isFocused: $isSecondaryAddressTextFieldFocused,
                            trailingIcon: .constant(""),
                            leadingIcon: .constant(""),
                            isSecureText: .constant(false)
                        )
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 16)
                
                Button(action: {
                    if isAllDetailsValid() {
                        
                    }
                }){
                    Text("Make Payment")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: brandColor))
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
    
    private func onChangeFullName(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            fullNameErrorText = "Required"
            isFullNameValid = false
        } else {
            fullNameErrorText = ""
            isFullNameValid = true
        }
    }
    
    private func onChangeMobileNumber(updatedText: String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        if trimmedText.isEmpty {
            mobileNumberErrorText = "Required"
            isMobileNumberValid = false
        } else if trimmedText.count < mobileNumberMinLength || trimmedText.count > mobileNumberMaxLength || !mobileNumberPredicate.evaluate(with: trimmedText) {
            mobileNumberErrorText = "Mobile number must be \(mobileNumberMaxLength) digits"
            isMobileNumberValid = false
        } else {
            mobileNumberErrorText = ""
            isMobileNumberValid = true
        }
    }
    
    private func onChangeEmailId(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if trimmedText.isEmpty {
            emailIdErrorText = "Required"
            isEmailIdValid = false
        } else if !emailPredicate.evaluate(with: trimmedText) {
            emailIdErrorText = "Invalid Email"
            isEmailIdValid = false
        } else {
            emailIdErrorText = ""
            isEmailIdValid = true
        }
    }
    
    private func onChangePostalCode(updatedText : String) {
        
    }
    
    private func onChangeCity(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            cityErrorText = "Required"
            isCityValid = false
        } else {
            cityErrorText = ""
            isCityValid = true
        }
    }
    
    private func onChangeState(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            stateErrorText = "Required"
            isStateValid = false
        } else {
            stateErrorText = ""
            isStateValid = true
        }
    }
    
    private func onChangeMainAddress(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            mainAddressErrorText = "Required"
            isMainAddressValid = false
        } else {
            mainAddressErrorText = ""
            isMainAddressValid = true
        }
    }
    
    private func isAllDetailsValid() -> Bool {
        var isAllValid = true
        
        if (isFullNameValid == nil || isFullNameValid == false) {
            onChangeFullName(updatedText: fullNameTextField)
            isAllValid = false
        }
        if (isMobileNumberValid == nil || isMobileNumberValid == false) {
            onChangeMobileNumber(updatedText: mobileNumberTextField)
            isAllValid = false
        }
        if (isEmailIdValid == nil || isEmailIdValid == false) {
            onChangeEmailId(updatedText: emailIdTextField)
            isAllValid = false
        }
        if (isPostalCodeValid == nil || isPostalCodeValid == false) {
            onChangePostalCode(updatedText: postalCodeTextField)
            isAllValid = false
        }
        if (isCityValid == nil || isCityValid == false) {
            onChangeCity(updatedText: cityTextField)
            isAllValid = false
        }
        if (isStateValid == nil || isStateValid == false) {
            onChangeState(updatedText: stateTextField)
            isAllValid = false
        }
        if (isMainAddressValid == nil || isMainAddressValid == false) {
            onChangeMainAddress(updatedText: mainAddressTextField)
            isAllValid = false
        }
        
        return isAllValid
    }
}

//struct AddAddressScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        AddAddressScreen()
//    }
//}
