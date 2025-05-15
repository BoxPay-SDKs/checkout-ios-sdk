//
//  CheckoutManager.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

@MainActor
public class CheckoutManager {
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
}
