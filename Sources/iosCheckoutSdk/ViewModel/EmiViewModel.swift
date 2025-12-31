import UIKit

@MainActor
class EmiViewModel: ObservableObject {
    @Published var isFirstLoad = true
    @Published var isLoading = false
    @Published var checkoutManager = CheckoutManager.shared
    private let userDataManager = UserDataManager.shared
    private let apiService = ApiService.shared
    @Published var emiDataClass: EmiDataClass = EmiDataClass(cards: [])
    @Published var duplicateEmiDataClass: EmiDataClass = EmiDataClass(cards: [])
    @Published var selectedCardType = "Credit Card"
    @Published var actions: PaymentAction?
    
    @Published var itemsCount = 0
    @Published var currencySymbol = ""
    @Published var totalAmount = ""
    @Published var brandColor = ""
    @Published var transactionId = ""

    func getEmiPaymentMethod() {
        Task {
            do {
                let data = try await apiService.request(
                    endpoint: "payment-methods",
                    responseType: [PaymentMethod].self
                )
                self.isFirstLoad = false
                
                var cardTypeDict: [String: [Bank]] = [:]

                for paymentMethod in data {
                    guard paymentMethod.type == "Emi" else { continue }

                    let title = paymentMethod.title
                    let emiCardName: String

                    if title?.contains("Credit") == true {
                        emiCardName = "Credit Card"
                    } else if title?.contains("Debit") == true {
                        emiCardName = "Debit Card"
                    } else {
                        emiCardName = "Others"
                    }

                    let emiBankImage = paymentMethod.logoUrl
                    guard let emiMethod = paymentMethod.emiMethod else { continue }

                    let bankName = emiCardName == "Others"
                        ? (emiMethod.cardlessEmiProviderTitle ?? "")
                        : (emiMethod.issuerTitle ?? "")

                    let effectiveInterestRate = emiMethod.effectiveInterestRate ?? 0.0
                    let bankInterestRate = emiCardName == "Others" ? 0.0 : effectiveInterestRate

                    var noApplicableOffer = false
                    var lowApplicableOffer = false
                    if let offers = paymentMethod.applicableOffers {
                        for offer in offers {
                            let discountType = offer.discount?.type
                            if discountType == "NoCostEmi" {
                                noApplicableOffer = true
                            }
                            if discountType == "LowCostEmi" {
                                lowApplicableOffer = true
                            }
                        }
                    }

                    let percentValue = noApplicableOffer
                        ? (emiMethod.merchantBorneInterestRate ?? 0.0)
                        : bankInterestRate
                    let percentString = "\(percentValue)"

                    let emi = EmiList(
                        duration: emiMethod.duration ?? 0,
                        percent: percentString,
                        amount: emiMethod.emiAmountLocaleFull ?? "",
                        totalAmount: emiMethod.totalAmountLocaleFull ?? "",
                        discount: emiMethod.merchantBorneInterestAmountLocaleFull,
                        interestCharged: lowApplicableOffer
                            ? emiMethod.interestChargedAmountLocaleFull ?? ""
                            : emiMethod.bankChargedInterestAmountLocaleFull ?? "",
                        noCostApplied: noApplicableOffer,
                        lowCostApplied: lowApplicableOffer,
                        processingFee: emiMethod.processingFee?.amountLocaleFull ?? "0",
                        code: paymentMethod.applicableOffers?.first?.code,
                        netAmount: emiMethod.netAmountLocaleFull ?? ""
                    )

                    let bank = Bank(
                        iconUrl: emiBankImage ?? "",
                        name: bankName,
                        percent: percentString,
                        isNoCostApplied: noApplicableOffer,
                        isLowCostApplied: lowApplicableOffer,
                        emiList: [emi],
                        cardLessEmiValue: emiMethod.cardlessEmiProviderValue ?? "",
                        issuerBrand: emiCardName == "Others" ? nil : emiMethod.issuer
                    )

                    if var banks = cardTypeDict[emiCardName] {
                        if let index = banks.firstIndex(where: { $0.name == bank.name }) {
                            banks[index].emiList.append(contentsOf: bank.emiList)
                            cardTypeDict[emiCardName] = banks
                        } else {
                            banks.append(bank)
                            cardTypeDict[emiCardName] = banks
                        }
                    } else {
                        cardTypeDict[emiCardName] = [bank]
                    }
                }

                let sortOrder = ["Credit Card", "Debit Card", "Others"]

                // Sort banks inside each card
                let sortedCardTypeDict: [String: [Bank]] = cardTypeDict.mapValues { banks in
                    banks.sorted { lhs, rhs in
                        if lhs.isNoCostApplied != rhs.isNoCostApplied {
                            return lhs.isNoCostApplied
                        } else if lhs.isLowCostApplied != rhs.isLowCostApplied {
                            return lhs.isLowCostApplied
                        } else {
                            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                        }
                    }
                }

                // Sort cards based on preferred cardType order
                let sortedCards = sortOrder.compactMap { key -> CardType? in
                    guard let banks = sortedCardTypeDict[key] else { return nil }
                    return CardType(cardType: key, banks: banks)
                }

                // Assign final
                let emiData = EmiDataClass(cards: sortedCards)
                self.emiDataClass = emiData
                self.duplicateEmiDataClass = emiData
                self.itemsCount = await checkoutManager.getItemsCount()
                self.currencySymbol = await checkoutManager.getCurrencySymbol()
                self.totalAmount = await checkoutManager.getTotalAmount()
                self.brandColor = await checkoutManager.getBrandColor()

            } catch {
                self.isFirstLoad = false
            }
        }
    }

    func initiatedOtherEmiPostRequest(instrumentValue: String) {
        self.isLoading = true
        Task {
            let instrumentDetails: [String: Any] = [
                "type": "emi/cardless",
                "emi": [
                    "provider": instrumentValue
                ]
            ]
            
            let deliveryAddress: [String: Any?] = await[
                "address1": userDataManager.getAddress1(),
                "address2": userDataManager.getAddress2(),
                "city": userDataManager.getCity(),
                "state": userDataManager.getState(),
                "countryCode": userDataManager.getCountryCode(),
                "postalCode": userDataManager.getPinCode(),
                "labelType": userDataManager.getLabelType(),
                "labelName": userDataManager.getLabelName()
            ]
            
            let isDeliveryEmpty = deliveryAddress.values.contains { value in
                if value == nil {
                    return true
                }
                if let str = value as? String {
                    return str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                return false // Non-string & non-nil values considered valid
            }
            
            let payload: [String: Any] = await[
                "browserData": [
                    "screenHeight": Int(UIScreen.main.bounds.height),
                    "screenWidth": Int(UIScreen.main.bounds.width),
                    "acceptHeader": "application/json",
                    "userAgentHeader": "iOS App",
                    "browserLanguage": Locale.current.identifier,
                    "ipAddress": "null",
                    "colorDepth": 24,
                    "javaEnabled": true,
                    "timeZoneOffSet": TimeZone.current.secondsFromGMT() / 60,
                    "packageId": Bundle.main.bundleIdentifier ?? "com.boxpay.checkout.sdk"
                ],
                "instrumentDetails": instrumentDetails,
                "shopper": [
                    "email": userDataManager.getEmail(),
                    "firstName": userDataManager.getFirstName(),
                    "lastName": userDataManager.getLastName(),
                    "phoneNumber": userDataManager.getPhone(),
                    "uniqueReference": userDataManager.getUniqueId(),
                    "dateOfBirth": userDataManager.getDOB(),
                    "panNumber": userDataManager.getPan(),
                    "deliveryAddress": isDeliveryEmpty ? nil : deliveryAddress
                ],
                "deviceDetails": [
                    "browser": "iOS",
                    "platformVersion": UIDevice.current.systemVersion,
                    "deviceType": UIDevice.current.model,
                    "deviceName": UIDevice.current.name,
                    "deviceBrandName": "Apple"
                ]
            ]
            
            guard JSONSerialization.isValidJSONObject(payload) else {
                self.isLoading = false
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                let data = try await apiService.request(
                    method: .POST,
                    headers: StringUtils.getRequestHeaders(),
                    body: jsonData,
                    responseType: GeneralPaymentInitilizationResponse.self
                )
                
                await checkoutManager.setStatus(data.status.status.uppercased())
                await checkoutManager.setTransactionId(data.transactionId)
                transactionId = data.transactionId
                
                actions = await PaymentActionUtils.handle(
                    timeStamp: data.transactionTimestampLocale,
                    reasonCode: data.status.reasonCode,
                    reason: data.status.reason,
                    methodType: "WALLET",
                    response: PaymentActionResponse(action: data.actions),
                    shopperVpa: ""
                )
            } catch {
                let errorDescription = error.localizedDescription.lowercased()
                
                if errorDescription.contains("expired") {
                    await checkoutManager.setStatus("EXPIRED")
                } else {
                    await checkoutManager.setStatus("FAILED")
                }
                
                actions = await PaymentActionUtils.handle(
                    timeStamp: "",
                    reasonCode: "",
                    reason: error.localizedDescription,
                    methodType: "",
                    response: PaymentActionResponse(action: nil),
                    shopperVpa: ""
                )
            }
        }
    }
    
    func clearAllFields() {
        isFirstLoad = true
        isLoading = false
        emiDataClass = EmiDataClass(cards: [])
        duplicateEmiDataClass = EmiDataClass(cards: [])
        selectedCardType = "Credit Card"
        
        itemsCount = 0
        currencySymbol = ""
        totalAmount = ""
        brandColor = ""
        transactionId = ""
    }
}
