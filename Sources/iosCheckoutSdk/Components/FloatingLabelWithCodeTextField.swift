import SwiftUI
import UIKit
import CountryPickerView

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

            CountryCodePhoneTextField(
                text: $text,
                isValid: $isValid,
                countryCode: $countryCode,
                isFocused: $isFocused,
                onChangeCode: { newCode in
                    onChangeCode(newCode)
                }
            )
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .frame(height: 50)
        }
    }
}

struct CountryCodePhoneTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var countryCode: String
    @Binding var isFocused: Bool

    var onChangeCode: ((String) -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let countryPickerView = CountryPickerView()
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.delegate = context.coordinator
        countryPickerView.translatesAutoresizingMaskIntoConstraints = false

        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.keyboardType = .phonePad
        textField.delegate = context.coordinator
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Enable tapping on country picker to open the modal
        countryPickerView.setCountryByCode(countryCode) // Initial setup
        countryPickerView.showCountryCodeInView = true

        context.coordinator.textField = textField
        context.coordinator.countryPickerView = countryPickerView

        container.addSubview(countryPickerView)
        container.addSubview(textField)

        NSLayoutConstraint.activate([
            countryPickerView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            countryPickerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countryPickerView.widthAnchor.constraint(equalToConstant: 100),

            textField.leadingAnchor.constraint(equalTo: countryPickerView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateBindings(text: text, code: countryCode)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isValid: $isValid, countryCode: $countryCode, onChangeCode: onChangeCode, isFocused: $isFocused)
    }

    class Coordinator: NSObject, UITextFieldDelegate, CountryPickerViewDelegate {
        
        @Binding var text: String
        @Binding var isValid: Bool?
        @Binding var countryCode: String
        @Binding var isFocused: Bool
        var onChangeCode: ((String) -> Void)?
        weak var textField: UITextField?
        weak var countryPickerView: CountryPickerView?

        init(text: Binding<String>, isValid: Binding<Bool?>, countryCode: Binding<String>, onChangeCode: ((String) -> Void)?, isFocused: Binding<Bool>) {
            _text = text
            _isValid = isValid
            _countryCode = countryCode
            self.onChangeCode = onChangeCode
            _isFocused = isFocused
        }

        func updateBindings(text: String, code: String) {
            if text != self.text {
                DispatchQueue.main.async {
                    self.text = text  // ✅ Safe to update binding outside view update cycle
                }
            }
            countryPickerView?.setCountryByCode(code)
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            self.text = textField.text ?? ""
            self.isValid = !text.isEmpty // Simplified
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
        }
        
        nonisolated func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
            print("\(country)")
        }
    }
}
