//
//  AddAddressViewModel.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//

import UIKit
import PhoneNumberKit

@MainActor
class AddAddressViewModel: ObservableObject {
    @Published var fullNameTextField = ""
    @Published var mobileNumberTextField = ""
    @Published var emailIdTextField = ""
    @Published var postalCodeTextField = ""
    @Published var postalCodeMaxLength = 6
    @Published var cityTextField = ""
    @Published var stateTextField = ""
    @Published var mainAddressTextField = ""
    @Published var secondaryAddressTextField = ""
    @Published var selectedCountryCode = "IN"
    @Published var selectedCountryNumberCode = "+91"
    @Published var countryTextField = "India"
    
    @Published var isFullNameTextFieldFocused = false
    @Published var isMobileNumberTextFieldFocused = false
    @Published var isEmailIdTextFieldFocused = false
    @Published var isPostalCodeTextFieldFocused = false
    @Published var isCityTextFieldFocused = false
    @Published var isStateTextFieldFocused = false
    @Published var isMainAddressTextFieldFocused = false
    @Published var isSecondaryAddressTextFieldFocused = false
    @Published var isCountryTextFieldFocused = false
    
    @Published var isFullNameValid : Bool? = nil
    @Published var isMobileNumberValid : Bool? = nil
    @Published var isEmailIdValid : Bool? = nil
    @Published var isPostalCodeValid : Bool? = nil
    @Published var isCityValid : Bool? = nil
    @Published var isStateValid : Bool? = nil
    @Published var isMainAddressValid : Bool? = nil
    
    @Published var fullNameErrorText = ""
    @Published var mobileNumberErrorText = ""
    @Published var emailIdErrorText = ""
    @Published var postalCodeErrorText = ""
    @Published var cityErrorText = ""
    @Published var stateErrorText = ""
    @Published var mainAddressErrorText = ""
    
    @Published var isShippingEnabled = false
    @Published var isShippingEditable = false
    @Published var isFullNameEnabled = false
    @Published var isFullNameEditable = false
    @Published var isMobileNumberEditable = false
    @Published var isMobileNumberEnabled = false
    @Published var isEmailIdEnabled = false
    @Published var isEmailIdEditable = false
    @Published var dataUpdationCompleted = false
    
    private let phoneNumberUtility = PhoneNumberUtility()
    private let apiService = ApiService.shared
    
    let emailRegex = "^(?!.*\\.\\.)(?!.*\\.\\@)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    let numberRegex = "^[0-9]+$"
    let userDataManager = UserDataManager.shared
    let checkoutManager = CheckoutManager.shared
    
    @Published var brandColor : String = ""
    
    @Published var address = ""
    @Published var addressLabelName = ""
    
    init() {
        Task {
            self.brandColor = await checkoutManager.getBrandColor()
            self.selectedCountryCode = await userDataManager.getCountryCode() ?? "IN"
            self.isShippingEnabled = await checkoutManager.getIsShippingAddressEnabled()
            self.isShippingEditable = await checkoutManager.getIsShippingAddressEditable()
            self.isFullNameEnabled = await checkoutManager.getIsFullNameEnabled()
            self.isFullNameEditable = await checkoutManager.getIsFullNameEditable()
            self.isMobileNumberEnabled = await checkoutManager.getIsMobileNumberEnabled()
            self.isMobileNumberEditable = await checkoutManager.getIsMobileNumberEditable()
            self.isEmailIdEnabled = await checkoutManager.getIsEmailIdEnabled()
            self.isEmailIdEditable = await checkoutManager.getIsEmailIdEditable()
            
            let firstName = await userDataManager.getFirstName() ?? ""
            let lastName = await userDataManager.getLastName() ?? ""
            self.fullNameTextField = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            do {
                let phoneNumberUtility = try phoneNumberUtility.parse(await userDataManager.getPhone() ?? "", withRegion: selectedCountryCode)
                self.mobileNumberTextField = String(phoneNumberUtility.nationalNumber)
                self.selectedCountryNumberCode = String(phoneNumberUtility.countryCode)
            } catch {
                self.mobileNumberTextField = ""
            }
            self.emailIdTextField = await userDataManager.getEmail() ?? ""
            self.postalCodeTextField = await userDataManager.getPinCode() ?? ""
            self.cityTextField = await userDataManager.getCity() ?? ""
            self.stateTextField = await userDataManager.getState() ?? ""
            self.mainAddressTextField = await userDataManager.getAddress1() ?? ""
            self.secondaryAddressTextField = await userDataManager.getAddress2() ?? ""
            
            address = await formattedAddress()
            let labelName = await userDataManager.getLabelName()
            addressLabelName = (labelName == nil || labelName?.isEmpty == true)
                ? await userDataManager.getLabelType() ?? ""
                : labelName ?? ""
        }
    }
    
    func onChangeFullName(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            fullNameErrorText = "Required"
            isFullNameValid = false
        } else {
            fullNameErrorText = ""
            isFullNameValid = true
        }
    }
    
    func onChangeCountryCodeTextField(newCountryCode: String, newName : String, newPhoneCode : String) {
        selectedCountryCode = newCountryCode
        selectedCountryNumberCode = newPhoneCode
        countryTextField = newName
    }
    
    func onChangeEmailId(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if trimmedText.isEmpty {
            emailIdErrorText = "Required"
            isEmailIdValid = false
        } else if !emailPredicate.evaluate(with: trimmedText) {
            emailIdErrorText = "Invalid Email"
            isEmailIdValid = false
        } else {
            emailIdErrorText = ""
            isEmailIdValid = true
        }
    }
    
    func onChangePostalCode(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            postalCodeErrorText = "Required"
            isPostalCodeValid = false
        } else if selectedCountryNumberCode == "+91" && trimmedText.count < 6 {
            postalCodeErrorText = "Zip/Postal code must be 6 digits"
            isPostalCodeValid = false
        } else {
            postalCodeErrorText = ""
            isPostalCodeValid = true
        }
    }
    
    func onChangeCity(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            cityErrorText = "Required"
            isCityValid = false
        } else {
            cityErrorText = ""
            isCityValid = true
        }
    }
    
    func onChangeState(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            stateErrorText = "Required"
            isStateValid = false
        } else {
            stateErrorText = ""
            isStateValid = true
        }
    }
    
    func onChangeMainAddress(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            mainAddressErrorText = "Required"
            isMainAddressValid = false
        } else {
            mainAddressErrorText = ""
            isMainAddressValid = true
        }
    }
    
    func isAllDetailsValid() async -> Bool {
        var isAllValid = true

        // Full Name
        let fullNameTrimmed = fullNameTextField.trimmingCharacters(in: .whitespaces)
        isFullNameValid = !fullNameTrimmed.isEmpty && isFullNameEnabled
        if isFullNameValid == false {
            onChangeFullName(updatedText: fullNameTextField)
            isAllValid = false
        }

        // Email
        let emailTrimmed = emailIdTextField.trimmingCharacters(in: .whitespaces)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailIdValid = !emailTrimmed.isEmpty && emailPredicate.evaluate(with: emailTrimmed) && isEmailIdEnabled
        if isEmailIdValid == false {
            onChangeEmailId(updatedText: emailIdTextField)
            isAllValid = false
        }

        // Postal Code
        if(isShippingEnabled) {
            let postalTrimmed = postalCodeTextField.trimmingCharacters(in: .whitespaces)
            if selectedCountryNumberCode == "+91" {
                isPostalCodeValid = !postalTrimmed.isEmpty && postalTrimmed.count >= 6
            } else {
                isPostalCodeValid = !postalTrimmed.isEmpty
            }
            if isPostalCodeValid == false {
                onChangePostalCode(updatedText: postalCodeTextField)
                isAllValid = false
            }

            // City
            let cityTrimmed = cityTextField.trimmingCharacters(in: .whitespaces)
            isCityValid = !cityTrimmed.isEmpty
            if isCityValid == false {
                onChangeCity(updatedText: cityTextField)
                isAllValid = false
            }

            // State
            let stateTrimmed = stateTextField.trimmingCharacters(in: .whitespaces)
            isStateValid = !stateTrimmed.isEmpty
            if isStateValid == false {
                onChangeState(updatedText: stateTextField)
                isAllValid = false
            }

            // Main Address
            let addressTrimmed = mainAddressTextField.trimmingCharacters(in: .whitespaces)
            isMainAddressValid = !addressTrimmed.isEmpty
            if isMainAddressValid == false {
                onChangeMainAddress(updatedText: mainAddressTextField)
                isAllValid = false
            }
        }
        let isServerValid = await toCheckValidityThroughAPI()
        isAllValid = isAllValid && isServerValid
        return isAllValid
    }
    
    func updateUserData() {
        Task {
            let (firstName, lastName) = extractNames(from: fullNameTextField)
            await userDataManager.setFirstName(firstName)
            await userDataManager.setLastName(lastName)
            await userDataManager.setPhone("\(selectedCountryNumberCode)\(mobileNumberTextField)")
            await userDataManager.setEmail(emailIdTextField)
            await userDataManager.setPinCode(postalCodeTextField)
            await userDataManager.setCountryCode(selectedCountryCode)
            await userDataManager.setCity(cityTextField)
            await userDataManager.setState(stateTextField)
            await userDataManager.setAddress1(mainAddressTextField)
            await userDataManager.setAddress2(secondaryAddressTextField)
            
            self.dataUpdationCompleted = true
        }
    }
    
    func extractNames(from fullName: String) -> (firstName: String, lastName: String) {
        let components = fullName.split(separator: " ")
        
        guard let first = components.first else {
            return ("", "")
        }

        let last = components.dropFirst().joined(separator: " ")
        
        return (String(first), last)
    }

    func formattedAddress() async -> String {
        let address1 = await userDataManager.getAddress1()
        let address2 = await userDataManager.getAddress2()
        let city = await userDataManager.getCity()
        let state = await userDataManager.getState()
        let postalCode = await userDataManager.getPinCode()

        let components = [address1, address2, city, state, postalCode]

        let filteredComponents = components
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return filteredComponents.joined(separator: ", ")
    }
    
    func toCheckValidityThroughAPI() async -> Bool {
        do {
            let payload: [String: Any] = await [
                "email": emailIdTextField,
                "uniqueReference" : userDataManager.getUniqueId(),
                "phoneNumber" : "\(selectedCountryNumberCode)\(mobileNumberTextField)"
            ]
            guard JSONSerialization.isValidJSONObject(payload),
                  let jsonData = try? JSONSerialization.data(withJSONObject: payload),
                  let _ = String(data: jsonData, encoding: .utf8) else {
                return false
            }
            let _: EmptyResponse = try await apiService.request(
                endpoint: "shoppers/validations",
                includeToken : false,
                method: .POST,
                body: jsonData,
                responseType: EmptyResponse.self
            )
            return true
        } catch let apiError as ApiErrorResponse {
            for item in apiError.fieldErrorItems {
                print("Field error:", item.message)
                let fieldName = item.message.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces) ?? ""
                let errorMessage = item.message.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                switch fieldName {
                case "email":
                    emailIdErrorText = "Invalid Email"
                    isEmailIdValid = false
                case "phoneNumber":
                    mobileNumberErrorText = !errorMessage.isEmpty ? errorMessage : "Invalid phone number"
                    isMobileNumberValid = false
                default:
                    continue
                }
            }
            return false
        } catch {
            print("Unexpected error:", error.localizedDescription)
            return false
        }
    }
}
