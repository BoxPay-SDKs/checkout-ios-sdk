//
//  CustomTextFieldRepresentable.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUI
import UIKit

// MARK: - Custom UITextField with padding adjustment
class PaddedTextField: UITextField {
    var leftPadding: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0))
    }
}

// MARK: - SwiftUI UIViewRepresentable Wrapper
struct CustomTextFieldRepresentable: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextFieldRepresentable

        init(_ parent: CustomTextFieldRepresentable) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
            parent.onFocusLost?()
        }

        @objc func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            parent.onChange?(textField.text ?? "")
        }

        @objc func trailingIconTapped() {
            parent.onTrailingIconTap?()
        }
    }

    // MARK: - Props
    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholder: String
    var onChange: ((String) -> Void)? = nil
    var onFocusLost: (() -> Void)? = nil

    var textColor: UIColor = .black
    var accentColor: UIColor = .black
    var font: UIFont = UIFont.systemFont(ofSize: 16)
    var keyboardType: UIKeyboardType = .default

    @Binding var trailingIconName: String?
    @Binding var leadingIconName: String?
    var onTrailingIconTap: (() -> Void)? = nil

    @Binding var isSecureText: Bool

    // MARK: - makeUIView
    func makeUIView(context: Context) -> UITextField {
        let textField = PaddedTextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .none
        textField.font = font
        textField.textColor = textColor
        textField.tintColor = accentColor
        textField.keyboardType = keyboardType
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChangeSelection(_:)), for: .editingChanged)
        textField.isSecureTextEntry = isSecureText

        let bundle = Bundle.module

        if let leadingIconName = leadingIconName, !leadingIconName.isEmpty {
            let leadingImage = UIImage(named: leadingIconName, in: bundle, compatibleWith: nil)
            let leadingButton = UIButton(type: .custom)
            leadingButton.setImage(leadingImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            leadingButton.tintColor = textColor
            leadingButton.imageView?.contentMode = .scaleAspectFit
            leadingButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            textField.leftView = leadingButton
            textField.leftViewMode = .always
            textField.leftPadding = 36
        } else {
            textField.leftPadding = 12
        }

        
        // Trailing icon
        if let trailingIconName = trailingIconName, !trailingIconName.isEmpty {
            let trailingImage = UIImage(named: trailingIconName, in: bundle, compatibleWith: nil)
            let trailingButton = UIButton(type: .custom)
            trailingButton.setImage(trailingImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            trailingButton.tintColor = textColor
            trailingButton.imageView?.contentMode = .scaleAspectFit
            trailingButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            trailingButton.addTarget(context.coordinator, action: #selector(Coordinator.trailingIconTapped), for: .touchUpInside)
            textField.rightView = trailingButton
            textField.rightViewMode = .always
        }

        return textField
    }

    // MARK: - updateUIView
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textColor = textColor
        uiView.tintColor = accentColor
        uiView.keyboardType = keyboardType
        uiView.isSecureTextEntry = isSecureText
        uiView.font = font
        uiView.placeholder = placeholder
        

        // Update trailing icon
        let currentIconName = (uiView.rightView as? UIButton)?.image(for: .normal)?.accessibilityIdentifier
        if let trailingIconName = trailingIconName, !trailingIconName.isEmpty {
            if currentIconName != trailingIconName {
                let bundle = Bundle.module
                let trailingImage = UIImage(named: trailingIconName, in: bundle, compatibleWith: nil)
                trailingImage?.accessibilityIdentifier = trailingIconName // Set identifier to compare

                let trailingButton = UIButton(type: .custom)
                trailingButton.setImage(trailingImage?.withRenderingMode(.alwaysOriginal), for: .normal)
                trailingButton.tintColor = textColor
                trailingButton.imageView?.contentMode = .scaleAspectFit
                trailingButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                trailingButton.addTarget(context.coordinator, action: #selector(Coordinator.trailingIconTapped), for: .touchUpInside)

                uiView.rightView = trailingButton
                uiView.rightViewMode = .always
            }
        } else {
            uiView.rightView = nil
        }
    }


    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
