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
            .padding(.top, 25)
            .padding(.bottom, 8)
            .padding(.leading, 12)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
        }
    }
}

struct CountryCodePhoneTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var countryCode: String
    @Binding var isFocused: Bool

    var onChangeCode: ((_ countryCode : String, _ name : String, _ phoneCode : String) -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let countryPickerView = CountryPickerView()
        countryPickerView.showPhoneCodeInView = true
        countryPickerView.showCountryCodeInView = false
        countryPickerView.delegate = context.coordinator
        countryPickerView.translatesAutoresizingMaskIntoConstraints = false

        let textField = UITextField()
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
        context.coordinator.performInitialBindingIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isValid: $isValid, countryCode: $countryCode, onChangeCode: onChangeCode, isFocused: $isFocused)
    }

    class Coordinator: NSObject, UITextFieldDelegate, CountryPickerViewDelegate {
        
        @Binding var text: String
        @Binding var isValid: Bool?
        @Binding var countryCode: String
        @Binding var isFocused: Bool
        var onChangeCode: ((_ countryCode : String, _ name : String, _ phoneCode : String) -> Void)?

        weak var textField: UITextField?
        weak var countryPickerView: CountryPickerView?

        private var didInitialUpdate = false  // ✅ Flag to ensure one-time setup

        init(
            text: Binding<String>,
            isValid: Binding<Bool?>,
            countryCode: Binding<String>,
            onChangeCode: ((_ countryCode : String, _ name : String, _ phoneCode : String) -> Void)?,
            isFocused: Binding<Bool>
        ) {
            _text = text
            _isValid = isValid
            _countryCode = countryCode
            self.onChangeCode = onChangeCode
            _isFocused = isFocused
        }

        // ✅ One-time setup when UI is ready
        func performInitialBindingIfNeeded() {
            guard !didInitialUpdate else { return }
            didInitialUpdate = true

            DispatchQueue.main.async {
                self.textField?.text = self.text
                self.countryPickerView?.setCountryByCode(self.countryCode)
            }
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            self.text = textField.text ?? ""
            self.isValid = !self.text.isEmpty // Simplified validity check
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
        }

        nonisolated func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
            print("\(country)")
            let code = country.code
            let name = country.name
            let phoneCode = country.phoneCode
            DispatchQueue.main.async {
                self.onChangeCode?(code, name, phoneCode)
            }
        }
    }

}
