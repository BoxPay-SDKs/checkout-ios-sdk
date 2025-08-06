import SwiftUI
import UIKit
import FlagPhoneNumber

struct FloatingLabelWithCodeTextField: View {
    let placeholder: String
    @Binding var countryCode: String    //  ISO Country Code (e.g., "US", "GB")
    @Binding var text: String            // Main text field (raw input)
    @Binding var isValid: Bool?
    @Binding var isFocused: Bool       // Focus state for main text field
    @Binding var isCodeFocused: Bool     // Focus state for code field (not really used anymore)
    var onChangeText: ((String) -> Void)? = nil
    var onChangeCode: ((String) -> Void)  // called when the country code changes
    @Binding var showCountryCodePicker : Bool

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

            FPNTextFieldWrapper(text: $text, isValid: $isValid, countryCode: $countryCode, showCountryCodePicker: $showCountryCodePicker, isFocused: $isFocused)
                .padding(.horizontal, 12) // Add padding
                .padding(.top, 4)
                .frame(height: 50)
                .onChange(of: countryCode) { newValue in
                    onChangeCode(newValue)  //Notify the parent view of country code changes
                }
        }
    }
}

struct FPNTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var isValid: Bool?
    @Binding var countryCode: String // ISO Country Code
    @Binding var showCountryCodePicker: Bool
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> FPNTextField {
        let textField = FPNTextField()
        textField.delegate = context.coordinator
        textField.displayMode = .list // Or .picker
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)

        return textField
    }

    func updateUIView(_ uiView: FPNTextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor class Coordinator: NSObject, FPNTextFieldDelegate {
          var parent: FPNTextFieldWrapper

          init(_ parent: FPNTextFieldWrapper) {
              self.parent = parent
          }
        nonisolated func fpnDisplayCountryList() {
              // Handle the display of the country list (e.g., present a modal)
              DispatchQueue.main.async {
                  self.parent.showCountryCodePicker = true
              }
          }

        nonisolated func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
              // Called when a country is selected
              DispatchQueue.main.async {
                  self.parent.countryCode = code // Update the country code
              }
          }

        nonisolated func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
            // Called when the phone number is validated
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
                self.parent.isValid = isValid // `isValid` is already Bool, so assign as is
            }
        }

          @objc func textFieldDidChange(_ textField: UITextField) {
              guard let fpnTextField = textField as? FPNTextField else {
                  return
              }
              DispatchQueue.main.async {
                   self.parent.text = fpnTextField.text ?? ""
              }

          }
      }
}
