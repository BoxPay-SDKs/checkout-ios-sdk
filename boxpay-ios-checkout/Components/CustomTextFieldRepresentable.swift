//
//  CustomTextFieldRepresentable.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 22/04/25.
//


import SwiftUI
import UIKit

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
        }

        @objc func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
            parent.onChange?(textField.text ?? "")
        }
    }

    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholder: String
    var onChange: ((String) -> Void)? = nil

    var textColor: UIColor = .black
    var accentColor: UIColor = .black
    var font: UIFont = UIFont.systemFont(ofSize: 16)

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.font = font
        textField.textColor = textColor
        textField.tintColor = accentColor
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChangeSelection(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textColor = textColor
        uiView.tintColor = accentColor
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

