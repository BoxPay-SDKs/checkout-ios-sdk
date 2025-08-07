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
    var onChangeCode: ((_ countryCode : String, _ name : String, _ phoneCode : String) -> Void)  // called when the country code changes

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
                onChangeCode: { newCountryCode, newName, newPhoneCode in
                    onChangeCode(newCountryCode, newName, newPhoneCode)
                }
            )
            .padding(.top, 22)
            .padding(.bottom, 8)
            .padding(.leading, 12)
            .frame(maxWidth: .infinity)
        }
    }
}

struct CountryCodePhoneTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var countryCode: String
    @Binding var isFocused: Bool

    var onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let countryPickerView = CountryPickerView()
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = false
        countryPickerView.delegate = context.coordinator
        countryPickerView.translatesAutoresizingMaskIntoConstraints = false
        countryPickerView.setCountryByCode(countryCode)

        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.delegate = context.coordinator
        textField.translatesAutoresizingMaskIntoConstraints = false

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
            context.coordinator.performInitialBindingIfNeeded()
            
            if let textField = context.coordinator.textField {
                if textField.text != text {
                    textField.text = text
                }
                
                if isFocused {
                    textField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
            }
        }

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            text: $text,
            isValid: $isValid,
            countryCode: $countryCode,
            onChangeCode: onChangeCode,
            isFocused: $isFocused
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate, CountryPickerViewDelegate {
        @Binding var text: String
        @Binding var isValid: Bool?
        @Binding var countryCode: String
        @Binding var isFocused: Bool

        var onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?

        weak var textField: UITextField?
        weak var countryPickerView: CountryPickerView?

        init(
            text: Binding<String>,
            isValid: Binding<Bool?>,
            countryCode: Binding<String>,
            onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?,
            isFocused: Binding<Bool>
        ) {
            self._text = text
            self._isValid = isValid
            self._countryCode = countryCode
            self.onChangeCode = onChangeCode
            self._isFocused = isFocused
        }

        // MARK: - UITextFieldDelegate

        func textFieldDidChangeSelection(_ textField: UITextField) {
            self.text = textField.text ?? ""
            
            // Validate number (placeholder logic, replace with actual validation)
            self.isValid = !self.text.isEmpty && self.text.allSatisfy { $0.isNumber }
        }

        func performInitialBindingIfNeeded() {
            textField?.text = text
            countryPickerView?.setCountryByCode(countryCode)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            self.isFocused = false
        }

        // MARK: - CountryPickerViewDelegate

        nonisolated func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
            let code = country.code
            let name = country.name
            let phoneCode = country.phoneCode
            DispatchQueue.main.async {
                self.countryCode = code
                self.onChangeCode?(code, name, phoneCode)
            }
        }
    }
}

