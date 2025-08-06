import SwiftUI
import PhoneNumberKit
import UIKit

struct FloatingLabelWithCodeTextField: View {
    let placeholder: String
    @Binding var countryCode: String    //  ISO Country Code (e.g., "US", "GB")
    @Binding var text: String            // Main text field (raw input)
    @Binding var isValid: Bool?
    @Binding var isFocused: Bool       // Focus state for main text field
    @Binding var isCodeFocused: Bool     // Focus state for code field (not really used anymore)
    var onChangeText: ((String) -> Void)? = nil
    var onChangeCode: ((String) -> Void)  // called when the country code changes

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    (isValid == false) ? Color(hex: "#E12121") :
                    (isFocused) ? Color(hex: "#2D2B32") : //isCodeFocused is no longer relevant
                    Color(hex: "#E6E6E6"),
                    lineWidth: 1
                )
                .background(Color.white)

            Text(placeholder)
                .foregroundColor((isValid == false) ? Color(hex: "#E12121") :
                                    (isFocused || !text.isEmpty || !countryCode.isEmpty) ? Color(hex: "#2D2B32") :
                                 Color(hex: "#E6E6E6"))
                .background(Color.white)
                .padding(.horizontal, 5)
                .scaleEffect((isFocused || !text.isEmpty || !countryCode.isEmpty) ? 0.8 : 1.0, anchor: .leading)
                .offset(y: (isFocused || !text.isEmpty || !countryCode.isEmpty) ? -22: 0)
                .padding(.leading, 12)
                .animation(.easeOut(duration: 0.2), value: isFocused || !text.isEmpty || !countryCode.isEmpty)
                .font(.custom("Poppins-Regular", size: (isFocused) ? 14 : 16))

            PhoneNumberTextFieldView(text: $text, isValid: $isValid, countryCode: $countryCode, isFocused: $isFocused)
                .padding(.horizontal, 12) // Add padding
                .padding(.top, 4)
                .frame(height: 50)
                .onChange(of: countryCode) { newValue in
                    onChangeCode(newValue)  //Notify the parent view of country code changes
                }
        }
    }
}


struct PhoneNumberTextFieldView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var countryCode: String
    @Binding var isFocused: Bool
    let phoneNumberKit = PhoneNumberKit()
    var keyboardType: UIKeyboardType = .phonePad

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let textField = PhoneNumberTextField(frame: .zero, phoneNumberKit: phoneNumberKit) // Initialize with phoneNumberKit
        textField.withFlag = true
        textField.withExamplePlaceholder = true
        textField.borderStyle = .roundedRect
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        return textField
    }

    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        uiView.text = text
        uiView.keyboardType = keyboardType
        uiView.withFlag = true
        uiView.withExamplePlaceholder = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PhoneNumberTextFieldView

        init(_ parent: PhoneNumberTextFieldView) {
            self.parent = parent
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            guard let phoneNumberTextField = textField as? PhoneNumberTextField else {
                return // Exit if the textField is not a PhoneNumberTextField
            }

            parent.text = phoneNumberTextField.text ?? ""
            parent.isValid = phoneNumberTextField.isValidNumber
            parent.countryCode = phoneNumberTextField.currentRegion // Directly assign the non-optional String
        }

         func textFieldDidBeginEditing(_ textField: UITextField) {
                parent.isFocused = true
            }

            func textFieldDidEndEditing(_ textField: UITextField) {
                parent.isFocused = false
            }


    }
}
