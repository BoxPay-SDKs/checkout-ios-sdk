//
//  CheckoutManager.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

public actor CheckoutManager {
    static let shared = CheckoutManager()

    private let baseUrlProd: String = "https://apis.boxpay.in"
    private let baseUrlTest: String = "https://test-apis.boxpay.tech"
    private var baseURL: String // Make this a variable to set based on environment
    private var mainToken: String = ""
    private var shopperToken: String = ""
    private var brandColor : String = "#000000"
    private var isSuccessScreenVisible:Bool = true
    private var currencySymbol: String = "₹"
    private var totalAmount : String = ""
    private var paymentFailedMessage : String = "You may have cancelled the payment or there was a delay in response. Please retry."
    private var status:String = "NOACTION"
    private var transactionId = ""
    private var itemsCount = 0
    
    private var isShippingAddressEnabled: Bool = false
    private var isShippingAddressEditable: Bool = false
    private var isFullNameEnabled: Bool = false
    private var isFullNameEditable: Bool = false
    private var isMobileNumberEnabled: Bool = false
    private var isMobileNumberEditable: Bool = false
    private var isEmailIdEnabled: Bool = false
    private var isEmailIdEditable: Bool = false
    private var isPANEnabled: Bool = false
    private var isPANEditable: Bool = false
    private var isDOBEnabled: Bool = false
    private var isDOBEditable: Bool = false

    private init() {
        // Set a default value (production by default)
        self.baseURL = baseUrlProd
    }

    // Getter methods
    func getBaseURL() -> String { return baseURL }
    func getMainToken() -> String { return mainToken }
    func getShopperToken() -> String { return shopperToken }
    func getBrandColor() -> String { return brandColor }
    func getIsSuccessScreenVisible() -> Bool {return isSuccessScreenVisible}
    func getCurrencySymbol() -> String {return currencySymbol}
    func getTotalAmount() -> String {return totalAmount}
    func getpaymentErrorMessage() -> String {return paymentFailedMessage}
    func getStatus() -> String {return status}
    func getTransactionId() -> String {return transactionId}
    func getItemsCount() -> Int {return itemsCount}
    func getIsShippingAddressEnabled() -> Bool {return isShippingAddressEnabled}
    func getIsShippingAddressEditable() -> Bool {return isShippingAddressEditable}
    func getIsFullNameEnabled() -> Bool {return isFullNameEnabled}
    func getIsFullNameEditable() -> Bool {return isFullNameEditable}
    func getIsMobileNumberEnabled() -> Bool {return isMobileNumberEnabled}
    func getIsMobileNumberEditable() -> Bool {return isMobileNumberEditable}
    func getIsEmailIdEnabled() -> Bool {return isEmailIdEnabled}
    func getIsEmailIdEditable() -> Bool {return isEmailIdEditable}
    func getIsPANEnabled() -> Bool {return isPANEnabled}
    func getIsPANEditable() -> Bool {return isPANEditable}
    func getIsDOBEnabled() -> Bool {return isDOBEnabled}
    func getIsDOBEditable() -> Bool {return isDOBEditable}

    // Setter methods
    func setBaseURL(_ isTestEnvironment: Bool?) {
        if let isTest = isTestEnvironment {
            baseURL = isTest ? baseUrlTest : baseUrlProd
        } else {
            baseURL = baseUrlProd // default to prod if nil
        }
    }
    
    func setMainToken(_ token: String) { mainToken = token }
    func setShopperToken(_ token: String) { shopperToken = token }
    func setBrandColor (_ color: String) { brandColor = color }
    func setIsSuccessScreenVisible(_ successScreen: Bool) {isSuccessScreenVisible = successScreen}
    func setCurrencySymbol(_ currency:String) {currencySymbol = currency}
    func setAmount(_ amount:String) {totalAmount = amount}
    func setStatus(_ stat:String) {status = stat}
    func setTransactionId(_ transaction:String) {transactionId = transaction}
    func setItemsCount(_ count:Int) {itemsCount = count}
    func setIsShippingAddressEnabled(_ shippingAddressEnabled:Bool) {isShippingAddressEnabled = shippingAddressEnabled}
    func setIsShippingAddressEditable(_ shippingAddressEditable: Bool) {isShippingAddressEditable = shippingAddressEditable}
    func setIsFullNameEnabled(_ fullNameEnabled : Bool) {isFullNameEnabled = fullNameEnabled}
    func setIsFullNameEditable(_ fullNameEditable : Bool) {isFullNameEditable = fullNameEditable}
    func setIsMobileNumberEnabled(_ mobileNumberEnabled: Bool) {isMobileNumberEnabled = mobileNumberEnabled}
    func setIsMobileNumberEditable(_ mobileNumberEditable : Bool) {isMobileNumberEditable = mobileNumberEditable}
    func setIsEmailIdEnabled(_ emailIdEnabled : Bool) {isEmailIdEnabled = emailIdEnabled}
    func setIsEmailIdEditable(_ emailIdEditable : Bool) {isEmailIdEditable = emailIdEditable}
    func setIsPANEnabled(_ panEnabled: Bool) {isPANEnabled = panEnabled}
    func setIsPANEditable(_ panEditable : Bool) {isPANEditable = panEditable}
    func setIsDOBEnabled(_ dobEnabled : Bool) {isDOBEnabled = dobEnabled}
    func setIsDOBEditable(_ dobEditable: Bool) {isDOBEditable = dobEditable}
    
    func clearAllFields() {
        mainToken = ""
        shopperToken = ""
        brandColor = "#000000"
        isSuccessScreenVisible = true
        currencySymbol = "₹"
        totalAmount = ""
        paymentFailedMessage = "You may have cancelled the payment or there was a delay in response. Please retry."
        status = "NOACTION"
        transactionId = ""
        itemsCount = 0
        
        isShippingAddressEnabled = false
        isShippingAddressEditable = false
        isFullNameEnabled = false
        isFullNameEditable = false
        isMobileNumberEnabled = false
        isMobileNumberEditable = false
        isEmailIdEnabled = false
        isEmailIdEditable = false
        isPANEnabled = false
        isPANEditable = false
        isDOBEnabled = false
        isDOBEditable = false

    }
}
