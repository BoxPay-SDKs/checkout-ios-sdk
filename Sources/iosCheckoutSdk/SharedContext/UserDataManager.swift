//
//  UserDataManager.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

public actor UserDataManager {
    static let shared = UserDataManager()

    private var firstNameStored: String? = nil
    private var lastNameStored: String? = nil
    private var emailStored: String? = nil
    private var phoneStored: String? = nil
    private var dobStored: String? = nil
    private var panStored : String? = nil
    private var address1Stored:String? = nil
    private var address2Stored: String? = nil
    private var cityStored : String? = nil
    private var stateStored : String? = nil
    private var countryCodeStored : String? = nil
    private var pincodeStored : String? = nil
    private var labelTypeStored: String? = nil
    private var labelNameStored : String? = nil
    private var uniqueIdStored : String?  = nil
    private var countryFullName : String? = nil

    private init() {}

    // Getter methods
    func getFirstName() -> String? {return firstNameStored}
    func getLastName() -> String? {return lastNameStored}
    func getEmail() -> String? {return emailStored}
    func getPhone() -> String? {return phoneStored}
    func getDOB() -> String? {return dobStored}
    func getPan() -> String? {return panStored}
    func getAddress1() -> String? {return address1Stored}
    func getAddress2() -> String? {return address2Stored}
    func getCity() -> String? {return cityStored}
    func getState() -> String? {return stateStored}
    func getCountryCode() -> String? {return countryCodeStored}
    func getPinCode() -> String? {return pincodeStored}
    func getLabelType() -> String? {return labelTypeStored}
    func getLabelName() -> String? {return labelNameStored}
    func getUniqueId() -> String? {return uniqueIdStored}
    func getCountryFullName() -> String? {return countryFullName}
    
    // setter methods
    func setFirstName(_ firstName:String?) {firstNameStored = firstName}
    func setLastName (_ lastName: String?) {lastNameStored = lastName}
    func setEmail(_ email : String?) {emailStored = email}
    func setPhone(_ phone : String?) {phoneStored = phone}
    func setDOB(_ dob:String?) {dobStored = dob}
    func setPan(_ pan:String?) {panStored = pan}
    func setAddress1(_ address1 : String?) {address1Stored = address1}
    func setAddress2(_ address2 : String?) {address2Stored = address2}
    func setCity(_ city:String?) {cityStored = city}
    func setState(_ state:String?) {stateStored = state}
    func setCountryCode(_ country: String?) {countryCodeStored = country}
    func setPinCode(_ pincode : String?) {pincodeStored = pincode}
    func setLabelType(_ labelType:String?) {labelTypeStored = labelType}
    func setLabelName(_ labelName:String?) {labelNameStored = labelName}
    func setUniqueId(_ uniqueId:String?) {uniqueIdStored = uniqueId}
    func setCountryFullName(_ fullName : String?) {countryFullName = fullName}
    
    func clearAllFields() {
        firstNameStored = nil
        lastNameStored = nil
        emailStored = nil
        phoneStored = nil
        dobStored = nil
        panStored = nil
        address1Stored = nil
        address2Stored = nil
        cityStored = nil
        stateStored = nil
        countryCodeStored = nil
        pincodeStored = nil
        labelTypeStored = nil
        labelNameStored = nil
        uniqueIdStored = nil
        countryFullName = nil
    }
}
