//
//  FloatingLabelTextField.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI

struct FloatingLabelTextField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isValid: Bool?
    var onChange: ((String) -> Void)? = nil
    @Binding var isFocused: Bool
    var keyboardType: UIKeyboardType = .default  // <- Add this
    var onFocusEnd : (() -> Void)? = nil
    @Binding var trailingIcon :String?
    @Binding var leadingIcon : String?
    var onClickIcon : (() -> Void)? = nil
    @Binding var isSecureText : Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isValid == false ? Color(hex: "#E12121") : isFocused ? Color(hex: "#2D2B32"): Color(hex: "#E6E6E6"),
                    lineWidth: 1
                )
                .background(Color.white)

            Text(placeholder)
                .foregroundColor(isValid == false ? Color(hex: "#E12121") : isFocused || !text.isEmpty ? Color(hex: "#2D2B32"): Color(hex: "#E6E6E6"))
                .background(Color.white)
                .padding(.horizontal, 5)
                .scaleEffect((isFocused || !text.isEmpty) ? 0.8 : 1.0, anchor: .leading)
                .offset(y: (isFocused || !text.isEmpty) ? -22: 0)
                .padding(.leading, (leadingIcon != nil && leadingIcon?.isEmpty == true) ? 12 : 36)
                .animation(.easeOut(duration: 0.2), value: isFocused || !text.isEmpty)
                .font(.custom("Poppins-Regular", size: isFocused ? 14 : 16))

            CustomTextFieldRepresentable(
                text: $text,
                isFocused: $isFocused,
                placeholder: "",
                onChange: onChange,
                onFocusLost: onFocusEnd,
                textColor: UIColor(Color(hex: "#0A090B")),
                accentColor: UIColor(Color(hex: "#2D2B32")),
                font: UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                keyboardType: keyboardType, // <- Pass it here
                trailingIconName:$trailingIcon,
                leadingIconName: $leadingIcon,
                onTrailingIconTap: onClickIcon,
                isSecureText: $isSecureText
            )
            .padding(.top, 12)
            .padding(.bottom, 8)
            .padding(.horizontal, 12)
            .autocapitalization(.none)
        }
    }
}
