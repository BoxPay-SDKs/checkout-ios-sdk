//
//  AddAddressViewModel.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 30/05/25.
//

import UIKit

@MainActor
class AddAddressViewModel: ObservableObject {
    @Published var fullNameTextField = ""
    @Published var mobileNumberTextField = ""
    @Published var mobileNumberMinLength = 10
    @Published var mobileNumberMaxLength = 10
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
    @Published var isCountryCodeTextFieldFocused = false
    
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
    
    @Published var countryData: [String: Country] = [:]
    @Published var countryNames: [String] = []
    private var allCountryNames: [String] = [] // Full list of countries
    
    @Published var countryCodes: [String] = []
    private var allCountryCodes: [String] = []
    
    @Published var isShippingEnabled = false
    @Published var isShippingEditable = false
    @Published var isFullNameEnabled = false
    @Published var isFullNameEditable = false
    @Published var isMobileNumberEditable = false
    @Published var isMobileNumberEnabled = false
    @Published var isEmailIdEnabled = false
    @Published var isEmailIdEditable = false
    @Published var dataUpdationCompleted = false

    
    let emailRegex = "^(?!.*\\.\\.)(?!.*\\.\\@)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    let numberRegex = "^[0-9]+$"
    let userDataManager = UserDataManager.shared
    let checkoutManager = CheckoutManager.shared
    
    @Published var brandColor : String = ""
    
    init() {
        Task {
            self.brandColor = await checkoutManager.getBrandColor()
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
            self.mobileNumberTextField = await userDataManager.getPhone() ?? ""
            self.emailIdTextField = await userDataManager.getEmail() ?? ""
            self.postalCodeTextField = await userDataManager.getPinCode() ?? ""
            self.cityTextField = await userDataManager.getCity() ?? ""
            self.stateTextField = await userDataManager.getState() ?? ""
            self.mainAddressTextField = await userDataManager.getAddress1() ?? ""
            self.secondaryAddressTextField = await userDataManager.getAddress2() ?? ""
            self.selectedCountryCode = await userDataManager.getCountryCode() ?? ""
            
            loadCountryData()
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
    
    func onChangeCountryTextField(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
                countryNames = allCountryNames
            } else {
                countryNames = allCountryNames.filter {
                    $0.lowercased().contains(trimmedText.lowercased())
                }.sorted()
            }
    }
    
    func onChangeCountryCodeTextField(updatedText : String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        
        if trimmedText.isEmpty {
            countryCodes = allCountryCodes
            } else {
                countryCodes = allCountryCodes.filter {
                    $0.lowercased().contains(trimmedText.lowercased())
                }.sorted()
            }
    }
    
    func onChangeMobileNumber(updatedText: String) {
        let trimmedText = updatedText.trimmingCharacters(in: .whitespaces)
        let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        if trimmedText.isEmpty {
            mobileNumberErrorText = "Required"
            isMobileNumberValid = false
        } else if trimmedText.count < mobileNumberMinLength || trimmedText.count > mobileNumberMaxLength || !mobileNumberPredicate.evaluate(with: trimmedText) {
            mobileNumberErrorText = "Mobile number must be \(mobileNumberMaxLength) digits"
            isMobileNumberValid = false
        } else {
            mobileNumberErrorText = ""
            isMobileNumberValid = true
        }
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
    
    func isAllDetailsValid() -> Bool {
        var isAllValid = true

        // Full Name
        let fullNameTrimmed = fullNameTextField.trimmingCharacters(in: .whitespaces)
        isFullNameValid = !fullNameTrimmed.isEmpty
        if isFullNameValid == false { isAllValid = false }

        // Mobile Number
        let mobileTrimmed = mobileNumberTextField.trimmingCharacters(in: .whitespaces)
        let mobilePredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        isMobileNumberValid = !mobileTrimmed.isEmpty &&
                              mobileTrimmed.count >= mobileNumberMinLength &&
                              mobileTrimmed.count <= mobileNumberMaxLength &&
                              mobilePredicate.evaluate(with: mobileTrimmed)
        if isMobileNumberValid == false { isAllValid = false }

        // Email
        let emailTrimmed = emailIdTextField.trimmingCharacters(in: .whitespaces)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isEmailIdValid = !emailTrimmed.isEmpty && emailPredicate.evaluate(with: emailTrimmed)
        if isEmailIdValid == false { isAllValid = false }

        // Postal Code
        let postalTrimmed = postalCodeTextField.trimmingCharacters(in: .whitespaces)
        if selectedCountryNumberCode == "+91" {
            isPostalCodeValid = !postalTrimmed.isEmpty && postalTrimmed.count >= 6
        } else {
            isPostalCodeValid = !postalTrimmed.isEmpty
        }
        if isPostalCodeValid == false { isAllValid = false }

        // City
        let cityTrimmed = cityTextField.trimmingCharacters(in: .whitespaces)
        isCityValid = !cityTrimmed.isEmpty
        if isCityValid == false { isAllValid = false }

        // State
        let stateTrimmed = stateTextField.trimmingCharacters(in: .whitespaces)
        isStateValid = !stateTrimmed.isEmpty
        if isStateValid == false { isAllValid = false }

        // Main Address
        let addressTrimmed = mainAddressTextField.trimmingCharacters(in: .whitespaces)
        isMainAddressValid = !addressTrimmed.isEmpty
        if isMainAddressValid == false { isAllValid = false }

        return isAllValid
    }

    
    func loadCountryData() {
            guard let url = Bundle.module.url(forResource: "CountryCodes", withExtension: "json") else {
                print("countryCodes.json not found")
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([String: Country].self, from: data)
                let sorted = decoded.sorted { $0.key < $1.key }

                DispatchQueue.main.async {
                    self.countryData = Dictionary(uniqueKeysWithValues: sorted)
                    self.countryCodes = sorted.map { $0.value.isdCode }
                    self.countryNames = sorted.map { $0.value.fullName }
                    self.allCountryCodes = sorted.map { $0.value.isdCode}
                    self.allCountryNames = sorted.map { $0.value.fullName }
                    self.updatePhoneLengths()
                    
                    if let (_, country) = self.countryData.first(where: { $0.key == self.selectedCountryCode }) {
                        self.countryTextField = country.fullName
                        self.selectedCountryNumberCode = country.isdCode
                    }
                    if !self.mobileNumberTextField.isEmpty, self.mobileNumberTextField.hasPrefix(self.selectedCountryNumberCode) {
                        self.mobileNumberTextField = String(self.mobileNumberTextField.dropFirst(self.selectedCountryNumberCode.count))
                    }
                }
            } catch {
                print("Error loading JSON: \(error)")
            }
        }

    func updatePhoneLengths() {
        if let lengths = countryData[selectedCountryCode]?.phoneNumberLength, !lengths.isEmpty {
            mobileNumberMinLength = lengths.min() ?? 0
            mobileNumberMaxLength = lengths.max() ?? 0
        } else {
            mobileNumberMinLength = 0
            mobileNumberMaxLength = 0
        }
    }
    
    func onSelectCountryPicker(selectedCountry: String) {
        if let (code, country) = countryData.first(where: { $0.value.fullName == selectedCountry }) {
            selectedCountryCode = code
            countryTextField = country.fullName
            selectedCountryNumberCode = country.isdCode
        }
        isCountryTextFieldFocused = false
        updatePhoneLengths()
    }

    func onSelectedCountryCodePicker(selectedCode : String) {
        if let (code, country) = countryData.first(where: { $0.value.isdCode == selectedCode }) {
            selectedCountryCode = code
            countryTextField = country.fullName
            selectedCountryNumberCode = country.isdCode
        }
        isCountryCodeTextFieldFocused = false
        updatePhoneLengths()
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

}
