import Foundation
import UIKit

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var isFirstLoad : Bool = true
    @Published var upiCollectMethod:Bool = false
    @Published var upiIntentMethod : Bool = false
    @Published var upiQrMethod : Bool = false
    @Published var cardsMethod: Bool = false
    @Published var walletsMethod : Bool = false
    @Published var netBankingMethod : Bool = false
    @Published var emiMethod: Bool = false
    @Published var bnplMethod: Bool = false
    @Published var actions: PaymentAction?
    @Published var recommendedIds : [SavedItemDataClass] = []
    @Published var savedCards : [SavedItemDataClass] = []
    
    @Published var isShippingEnabled = false
    @Published var isShippingEditable = false
    @Published var isFullNameEnabled = false
    @Published var isFullNameEditable = false
    @Published var isMobileNumberEditable = false
    @Published var isMobileNumberEnabled = false
    @Published var isEmailIdEnabled = false
    @Published var isEmailIdEditable = false
    
    @Published var fullNameText = ""
    @Published var phoneNumberText = ""
    @Published var emailIdText = ""
    @Published var isAddressScreenRequiredToCompleteDetails = false
    @Published var addressLabelName = ""

    @Published var checkoutManager = CheckoutManager.shared
    let userDataManager = UserDataManager.shared
    let apiManager = ApiService.shared
    private var hasFetechedCheckoutDetails = false

    @Published var sessionData: CheckoutSession? {
        didSet {
            Task { await processSessionData() }
        }
    }
    
    @Published var errorReason: String = ""
    @Published var itemsCount: Int = 0

    var paymentOptionList: [PaymentMethod] {
        sessionData?.configs.paymentMethods ?? []
    }
    
    @Published var brandColor = ""
    @Published var address = ""
    
    @Published var isInitialized = false
        func initialize(token: String, shopperToken: String?, config: ConfigOptions?, callback: @escaping (PaymentResultObject) -> Void) {
            Task {
                PaymentCallBackManager.shared.setCallback(callback)
                await checkoutManager.setBaseURL(config?[ConfigurationOption.enableTextEnv] == true)
                await checkoutManager.setIsSuccessScreenVisible(config?[ConfigurationOption.showBoxpaySuccessScreen] ?? true)
                
                if !token.isEmpty {
                    await checkoutManager.setMainToken(token)
                }
                if let shopperTokenPresent = shopperToken {
                    await checkoutManager.setShopperToken(shopperTokenPresent)
                }

                isInitialized = true
                getCheckoutSession()
            }
        }
    
    func getRecommendedFields(shopperToken:String) {
        Task {
            do {
                guard let uniqueId = await userDataManager.getUniqueId() else {
                    return
                }
                let response = try await apiManager.request(
                    endpoint: "shoppers/\(uniqueId)/recommended-instruments",
                    method: .GET,
                    headers: [
                        "Authorization" : "Session \(shopperToken)"
                    ],
                    body: nil,
                    responseType: [RecommendedResponse].self
                )
                var localRecommended: [SavedItemDataClass] = []
                var localSavedCards: [SavedItemDataClass] = []

                // Iterate over each item in the API response
                for item in response {
                    // Create the SavedItemDataClass instance by mapping fields.
                    // It's safer to only create an item if it has a unique identifier.
                    guard let itemId = item.instrumentRef else {
                        // Skip this item if it doesn't have an instrumentRef to use as an ID
                        continue
                    }

                    let savedItem = SavedItemDataClass(
                        id: itemId,
                        displayName: item.holderName ?? "",
                        displayNumber: item.displayValue ?? "",
                        logoUrl: item.logoUrl ?? "",
                        instrumentTypeValue: item.instrumentRef ?? ""
                    )

                    // Sort the item into the correct list based on its type.
                    // We'll assume 'card' type goes to savedCards, and others are recommended.
                    if item.type == "Card" {
                        localSavedCards.append(savedItem)
                    } else {
                        localRecommended.append(savedItem)
                    }
                }
                self.recommendedIds = localRecommended
                self.savedCards = localSavedCards
            }
        }
    }

    /// Fetches the checkout session using the main token
    func getCheckoutSession() {
        guard !hasFetechedCheckoutDetails else { return }

        Task {
            do {
                let data: CheckoutSession = try await apiManager.request(
                    endpoint: nil,
                    method: .GET,
                    body: nil,
                    responseType: CheckoutSession.self
                )

                self.hasFetechedCheckoutDetails = true

                let status = data.status?.uppercased() ?? ""
                let txnId = data.lastTransactionId ?? ""

                // You can still await these even from MainActor context
                await checkoutManager.setStatus(status)
                await checkoutManager.setTransactionId(txnId)

                self.actions = await PaymentActionUtils.handle(
                    timeStamp: data.sessionExpiryTimestampLocale,
                    reasonCode: "",
                    reason: "",
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
                self.sessionData = data

            } catch {
                self.actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: "",
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
        }
    }

    private func processSessionData() async {
        guard let sessionData = sessionData else { return }

        if let items = sessionData.paymentDetails.order?.items {
            let total = items.reduce(0) { sum, item in
                sum + (item.quantity > 0 ? item.quantity : 1)
            }
            itemsCount = total
            await checkoutManager.setItemsCount(total)
        }

        let data = sessionData.paymentDetails.money
            await checkoutManager.setCurrencySymbol(getCurrencySymbol(from: data.currencyCode))
            await checkoutManager.setAmount(data.amountLocaleFull ?? "")
        

        let paymentMethods = sessionData.configs.paymentMethods
            for paymentMethod in paymentMethods {
                switch paymentMethod.type {
                case "Wallet":
                    walletsMethod = true
                case "Card":
                    cardsMethod = true
                case "NetBanking":
                    netBankingMethod = true
                case "BuyNowPayLater":
                    bnplMethod = true
                case "Emi":
                    emiMethod = true
                default:
                    break
                }

                if paymentMethod.brand == "UpiQr" {
                    upiQrMethod = true
                }
                if paymentMethod.brand == "UpiCollect" {
                    upiCollectMethod = true
                }
                if paymentMethod.brand == "UpiIntent" {
                    upiIntentMethod = true
                }
            }
        
        await checkoutManager.setBrandColor(sessionData.merchantDetails.checkoutTheme.primaryButtonColor ?? "#1CA672")
        brandColor = sessionData.merchantDetails.checkoutTheme.primaryButtonColor ?? "#1CA672"
        
        for field in sessionData.configs.enabledFields {
                switch field.field {
                case "SHIPPING_ADDRESS":
                    await checkoutManager.setIsShippingAddressEnabled(true)
                    await checkoutManager.setIsShippingAddressEditable(field.editable)
                case "SHOPPER_NAME":
                    await checkoutManager.setIsFullNameEnabled(true)
                    await checkoutManager.setIsFullNameEditable(field.editable)
                case "SHOPPER_PHONE":
                    await checkoutManager.setIsMobileNumberEnabled(true)
                    await checkoutManager.setIsMobileNumberEditable(field.editable)
                case "SHOPPER_EMAIL":
                    await checkoutManager.setIsEmailIdEnabled(true)
                    await checkoutManager.setIsEmailIdEditable(field.editable)
                case "SHOPPER_PAN":
                    await checkoutManager.setIsPANEnabled(true)
                    await checkoutManager.setIsPANEditable(field.editable)
                case "SHOPPER_DOB":
                    await checkoutManager.setIsDOBEnabled(true)
                    await checkoutManager.setIsDOBEditable(field.editable)
                default:
                    break
                }
            }
        

        let userData = sessionData.paymentDetails.shopper
            await userDataManager.setFirstName(userData.firstName)
            await userDataManager.setLastName(userData.lastName)
            await userDataManager.setEmail(userData.email)
            await userDataManager.setPhone(userData.phoneNumber)
            await userDataManager.setUniqueId(userData.uniqueReference)
            await userDataManager.setAddress1(userData.deliveryAddress?.address1)
            await userDataManager.setAddress2(userData.deliveryAddress?.address2)
            await userDataManager.setCity(userData.deliveryAddress?.city)
            await userDataManager.setState(userData.deliveryAddress?.state)
            await userDataManager.setCountryCode(userData.deliveryAddress?.countryCode)
            await userDataManager.setPinCode(userData.deliveryAddress?.postalCode)
            await userDataManager.setLabelType(userData.deliveryAddress?.labelType)
            await userDataManager.setLabelName(userData.deliveryAddress?.labelName)
            await userDataManager.setDOB(userData.dateOfBirth)
            await userDataManager.setPan(userData.panNumber)
        
        let shopperToken = await checkoutManager.getShopperToken()
        if (!shopperToken.isEmpty) {
            getRecommendedFields(shopperToken: shopperToken)
        }
        address = await formattedAddress()
        let labelName = await userDataManager.getLabelName()
        addressLabelName = (labelName == nil || labelName?.isEmpty == true)
            ? await userDataManager.getLabelType() ?? ""
            : labelName ?? ""

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
        self.fullNameText = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        self.phoneNumberText = await userDataManager.getPhone() ?? ""
        self.emailIdText = await userDataManager.getEmail() ?? ""
        
        let isAddressMissing = address.isEmpty && isShippingEnabled
        let isPersonalInfoMissing = (fullNameText.isEmpty || emailIdText.isEmpty || phoneNumberText.isEmpty) &&
                                    (isFullNameEnabled || isMobileNumberEnabled || isEmailIdEnabled)

        if isAddressMissing || isPersonalInfoMissing {
            self.isAddressScreenRequiredToCompleteDetails = true
        }
        
        self.isFirstLoad = false
    }

    func getCurrencySymbol(from currencyCode: String?) -> String {
        guard let code = currencyCode else { return "₹" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        
        // This will return the symbol for the currency, e.g., "$", "€", "₹", etc.
        return formatter.currencySymbol ?? "₹"
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

}
