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

    /// Fetches the checkout session using the main token
    func getCheckoutSession() {
        guard !hasFetechedCheckoutDetails else { return }

        Task {
            do {
                let data: CheckoutSession = try await apiManager.request(
                    endpoint: nil,
                    method: .GET,
                    headers: ["Content-Type": "application/json"],
                    body: nil,
                    responseType: CheckoutSession.self
                )

                self.hasFetechedCheckoutDetails = true

                let status = data.status?.uppercased() ?? ""
                let txnId = data.lastTransactionId ?? ""

                // You can still await these even from MainActor context
                await checkoutManager.setStatus(status)
                await checkoutManager.setTransactionId(txnId)

                self.actions = CommonFunctions.handle(
                    timeStamp: data.sessionExpiryTimestampLocale,
                    reasonCode: "",
                    reason: "",
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
                self.sessionData = data

            } catch {
                self.actions = CommonFunctions.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: "",
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
                print("=======error \(error)")
            }
        }
        self.isFirstLoad = false
    }

    private func processSessionData() async {
        guard let sessionData = sessionData else { return }

        if let items = sessionData.paymentDetails.order?.items {
            let total = items.reduce(0) { sum, item in
                sum + (item.quantity > 0 ? item.quantity : 1)
            }
            itemsCount = total
            await checkoutManager.setItemsCount(total)
            print("Total items count: \(itemsCount)")
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
        
        print(sessionData)
    }

    func getCurrencySymbol(from currencyCode: String?) -> String {
        guard let code = currencyCode else { return "₹" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        
        // This will return the symbol for the currency, e.g., "$", "€", "₹", etc.
        return formatter.currencySymbol ?? "₹"
    }
}
