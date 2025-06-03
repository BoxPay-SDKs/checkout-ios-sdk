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
    @Published var countryCodes: [String] = []
    @Published var countryNames: [String] = []
    private var allCountryNames: [String] = [] // Full list of countries

    
    let emailRegex = "^(?!.*\\.\\.)(?!.*\\.\\@)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    let numberRegex = "^[0-9]+$"
    let userDataManager = UserDataManager.shared
    let checkoutManager = CheckoutManager.shared
    
    @Published var brandColor : String = ""
    
    init() {
        Task {
            self.brandColor = await checkoutManager.getBrandColor()
            let firstName = await userDataManager.getFirstName() ?? ""
            let lastName = await userDataManager.getLastName() ?? ""
            self.fullNameTextField = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            self.mobileNumberTextField = await userDataManager.getPhone() ?? ""
            self.emailIdTextField = await userDataManager.getEmail() ?? ""
            self.postalCodeTextField = await userDataManager.getPinCode() ?? ""
            self.cityTextField = await userDataManager.getCity() ?? ""
            self.stateTextField = await userDataManager.getState() ?? ""
            self.cityTextField = await userDataManager.getCity() ?? ""
            self.mainAddressTextField = await userDataManager.getAddress1() ?? ""
            self.secondaryAddressTextField = await userDataManager.getAddress2() ?? ""
        }
        loadCountryData()
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
        
        if (isFullNameValid == nil || isFullNameValid == false) {
            onChangeFullName(updatedText: fullNameTextField)
            isAllValid = false
        }
        if (isMobileNumberValid == nil || isMobileNumberValid == false) {
            onChangeMobileNumber(updatedText: mobileNumberTextField)
            isAllValid = false
        }
        if (isEmailIdValid == nil || isEmailIdValid == false) {
            onChangeEmailId(updatedText: emailIdTextField)
            isAllValid = false
        }
        if (isPostalCodeValid == nil || isPostalCodeValid == false) {
            onChangePostalCode(updatedText: postalCodeTextField)
            isAllValid = false
        }
        if (isCityValid == nil || isCityValid == false) {
            onChangeCity(updatedText: cityTextField)
            isAllValid = false
        }
        if (isStateValid == nil || isStateValid == false) {
            onChangeState(updatedText: stateTextField)
            isAllValid = false
        }
        if (isMainAddressValid == nil || isMainAddressValid == false) {
            onChangeMainAddress(updatedText: mainAddressTextField)
            isAllValid = false
        }
        
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
                    self.countryCodes = sorted.map { $0.key }
                    self.countryNames = sorted.map { $0.value.fullName }
                    self.allCountryNames = sorted.map { $0.value.fullName }
                    self.updatePhoneLengths()
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
            print("selectedCountryCode \(selectedCountryCode)")
            print("selectedCountryName \(countryTextField)")
            print("selectedCountryNumberCode \(selectedCountryNumberCode)")
        } else {
            print("Selected country not found in data")
        }
        countryNames = []
    }

}
