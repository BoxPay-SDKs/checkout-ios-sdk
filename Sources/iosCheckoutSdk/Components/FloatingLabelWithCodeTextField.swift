//
//  FloatingLabelWithCodeTextField.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 03/06/25.
//


import SwiftUI
import UIKit

struct FloatingLabelWithCodeTextField: View {
    let placeholder: String
    @Binding var countryCode: String    // Editable code field
    @Binding var text: String            // Main text field
    @Binding var isValid: Bool?
    @Binding var isFocused: Bool         // Focus state for main text field
    @Binding var isCodeFocused: Bool     // Focus state for code field
    var onChangeText: ((String) -> Void)? = nil
    var onChangeCode: ((String) -> Void)
    var onFocusEnd : (() -> Void)? = nil
    var keyboardType: UIKeyboardType = .default
    @Binding var trailingIcon :String?
    @Binding var leadingIcon : String?
    var onClickIcon : (() -> Void)? = nil
    @Binding var isSecureText : Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    (isValid == false) ? Color(hex: "#E12121") :
                    (isFocused || isCodeFocused) ? Color(hex: "#2D2B32") :
                    Color(hex: "#E6E6E6"),
                    lineWidth: 1
                )
                .background(Color.white)

            Text(placeholder)
                .foregroundColor((isValid == false) ? Color(hex: "#E12121") :
                                 (isFocused || isCodeFocused || !text.isEmpty) ? Color(hex: "#2D2B32") :
                                 Color(hex: "#E6E6E6"))
                .background(Color.white)
                .padding(.horizontal, 5)
                .scaleEffect((isFocused || isCodeFocused || !text.isEmpty) ? 0.8 : 1.0, anchor: .leading)
                .offset(y: (isFocused || isCodeFocused || !text.isEmpty) ? -22: 0)
                .padding(.leading, 12)
                .animation(.easeOut(duration: 0.2), value: isFocused || isCodeFocused || !text.isEmpty)
                .font(.custom("Poppins-Regular", size: (isFocused || isCodeFocused) ? 14 : 16))

            HStack(spacing: 0) {
                // Small editable country code text field
                HStack(spacing: 0) {
                    TextField("", text: $countryCode, onEditingChanged: { focused in
                        isCodeFocused = focused
                    })
                    .keyboardType(.phonePad)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(Color(hex: "#0A090B"))
                    .multilineTextAlignment(.leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.leading, 12)
                    .onChange(of: countryCode) { newValue in
                        onChangeCode(newValue)
                    }
                    Image(frameworkAsset: "chevron")
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(180))
                }
                .frame(width: 70)
                .padding(.top, 2)
                
                // Main custom text field
                CustomTextFieldRepresentable(
                    text: $text,
                    isFocused: $isFocused,
                    placeholder: "",
                    onChange: onChangeText,
                    onFocusLost: onFocusEnd,
                    textColor: UIColor(Color(hex: "#0A090B")),
                    accentColor: UIColor(Color(hex: "#2D2B32")),
                    font: UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                    keyboardType: keyboardType,
                    trailingIconName: $trailingIcon,
                    leadingIconName: $leadingIcon,
                    onTrailingIconTap: onClickIcon,
                    isSecureText: $isSecureText
                )
                .padding(.top, 12)
                .padding(.bottom, 8)
                .padding(.trailing, 12)
            }
        }
    }
}
