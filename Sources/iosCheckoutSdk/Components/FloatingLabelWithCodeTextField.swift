import SwiftUI
import UIKit
import CountryPickerView
import PhoneNumberKit

struct FloatingLabelWithCodeTextField: View {
    let placeholder: String
    @Binding var countryCode: String    //  ISO Country Code (e.g., "US", "GB")
    @Binding var text: String            // Main text field (raw input)
    @Binding var isValid: Bool?
    @Binding var isFocused: Bool       // Focus state for main text field
    @Binding var isCodeFocused: Bool     // Focus state for code field (not really used anymore)
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
                phoneNumber: $text,
                countryCode: $countryCode,
                isFocused: $isFocused,
                onChangeCode: { newCountryCode, newName, newPhoneCode in
                    onChangeCode(newCountryCode, newName, newPhoneCode)
                }
            )
            .textFieldStyle(PlainTextFieldStyle())
            .frame(height: 40)
            .padding(.vertical, 0)
        }
    }
}

struct CountryCodePhoneTextField: UIViewRepresentable {
    @Binding var phoneNumber: String
    @Binding var countryCode: String
    @Binding var isFocused: Bool
    
    var onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            phoneNumber: $phoneNumber,
            countryCode: $countryCode,
            isFocused: $isFocused,
            onChangeCode: onChangeCode
        )
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.delegate = context.coordinator
        context.coordinator.textField = textField

        let picker = CountryPickerView()
        picker.delegate = context.coordinator
        picker.showPhoneCodeInView = true
        picker.showCountryCodeInView = false
        picker.setCountryByCode(countryCode)
        context.coordinator.countryPickerView = picker

        textField.leftView = picker
        textField.leftViewMode = .always

        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let textField = context.coordinator.textField else { return }

        // Don't update @Binding here — only update the UITextField's visible text
        do {
            let parsedNumber = try context.coordinator.phoneNumberUtility.parse(phoneNumber, withRegion: countryCode)
            let nationalNumber = String(parsedNumber.nationalNumber)

            if textField.text != nationalNumber {
                textField.text = nationalNumber
            }
        } catch {
            // If parsing fails, show raw value (still don't touch the @Binding)
            if textField.text != phoneNumber {
                textField.text = phoneNumber
            }
        }
    }


    class Coordinator: NSObject, UITextFieldDelegate, CountryPickerViewDelegate {
        @Binding var phoneNumber: String
        @Binding var countryCode: String
        @Binding var isFocused: Bool

        var onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?
        let phoneNumberUtility = PhoneNumberUtility()
        
        weak var textField: UITextField?
        weak var countryPickerView: CountryPickerView?


        init(
            phoneNumber: Binding<String>,
            countryCode: Binding<String>,
            isFocused: Binding<Bool>,
            onChangeCode: ((_ countryCode: String, _ name: String, _ phoneCode: String) -> Void)?
        ) {
            self._phoneNumber = phoneNumber
            self._countryCode = countryCode
            self._isFocused = isFocused
            self.onChangeCode = onChangeCode
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            let number = textField.text ?? ""

            do {
                let parsedNumber = try phoneNumberUtility.parse(number, withRegion: countryCode)
                let nationalNumber = String(parsedNumber.nationalNumber)
                
                phoneNumber = nationalNumber
                textField.text = nationalNumber
            } catch {
                phoneNumber = number
            }
        }


        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
        }

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

