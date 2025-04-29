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
    @Binding var leadingIconName: String?  // <- Add this
    var onTrailingIconTap: (() -> Void)? = nil
    
    @Binding var isSecureText: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.font = font
        textField.textColor = textColor
        textField.tintColor = accentColor
        textField.keyboardType = keyboardType
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChangeSelection(_:)), for: .editingChanged)
        
        textField.isSecureTextEntry = isSecureText

        // Add trailing icon if provided
        let bundle = Bundle(for: TestClass.self)
        
        // Add leading icon (if provided)
        if let leadingIconName = leadingIconName, !leadingIconName.isEmpty {
            let leadingImage = UIImage(named: leadingIconName, in: bundle, compatibleWith: nil)
            let leadingButton = UIButton(type: .custom)
            leadingButton.setImage(leadingImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            leadingButton.tintColor = textColor
            leadingButton.imageView?.contentMode = .scaleAspectFit
            leadingButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            textField.leftView = leadingButton
            textField.leftViewMode = .always
        }

        // Add trailing icon (if provided)
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

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.textColor = textColor
        uiView.tintColor = accentColor
        uiView.keyboardType = keyboardType
        uiView.isSecureTextEntry = isSecureText
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
