//
//  EmiViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import UIKit

@MainActor
class EmiViewModel : ObservableObject {
    @Published var isFirstLoad = true
    @Published var isLoading = false
    @Published var checkoutManager = CheckoutManager.shared
    private var userDataManager = UserDataManager.shared
    @Published var apiService = ApiService.shared
    @Published var emiDataClass : EmiDataClass = EmiDataClass(cards: [])
    @Published var duplicateEmiDataClass : EmiDataClass = EmiDataClass(cards: [])
    @Published var selectedCardType = "Credit Card"
    @Published var actions : PaymentAction?
    
    func getEmiPaymentMethod() {
        apiService.request(
            endpoint: "payment-methods",
            responseType: [PaymentMethod].self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isFirstLoad = false
                switch result {
                case .success(let data):
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

                        // FIXED: Use `paymentMethod.applicableOffers`
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

                    // Step 1: Sort banks inside each card
                    let sortedCardTypeDict: [String: [Bank]] = cardTypeDict.mapValues { (banks: [Bank]) in
                        return banks.sorted { (lhs: Bank, rhs: Bank) in
                            if lhs.isNoCostApplied != rhs.isNoCostApplied {
                                return lhs.isNoCostApplied // true first
                            } else if lhs.isLowCostApplied != rhs.isLowCostApplied {
                                return lhs.isLowCostApplied // true first
                            } else {
                                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                            }
                        }
                    }


                    // Step 2: Sort cards based on preferred cardType order
                    let sortedCards = sortOrder.compactMap { key -> CardType? in
                        guard let banks = sortedCardTypeDict[key] else { return nil }
                        return CardType(cardType: key, banks: banks)
                    }

                    // Final assignment
                    let emiData = EmiDataClass(cards: sortedCards)
                    self?.emiDataClass = emiData
                    self?.duplicateEmiDataClass = self?.emiDataClass ?? EmiDataClass(cards: [])

                case .failure(let error):
                    print("=======error \(error)")
                }
            }
        }

    }
    
    func initiatedOtherEmiPostRequest(instrumentValue:String) {
        // Construct instrumentDetails
        self.isLoading = true
            let instrumentDetails: [String: Any] = [
                "type": "emi/cardless",
                "emi" : [
                    "provider" : instrumentValue
                ]
            ]

            // Construct delivery address
            let deliveryAddress: [String: Any?] = [
                "address1": userDataManager.getAddress1(),
                "address2": userDataManager.getAddress2(),
                "city": userDataManager.getCity(),
                "state": userDataManager.getState(),
                "countryCode": userDataManager.getCountryCode(),
                "postalCode": userDataManager.getPinCode(),
                "labelType": userDataManager.getLabelType(),
                "labelName": userDataManager.getLabelName()
            ]

            let isDeliveryEmpty = deliveryAddress.values.allSatisfy { value in
                (value as? String)?.isEmpty ?? true
            }
        

            let payload: [String: Any] = [
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
            print("❌ Invalid JSON")
            return
        }

        let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: [])
        
        if let json = jsonData, let jsonString = String(data: json, encoding: .utf8) {
            print("📤 JSON Payload:\n\(jsonString)")
        }

        
        apiService.request(
            method : .POST,
            headers: [
                "Content-Type": "application/json",
                "X-REQUEST-ID": CommonFunctions.generateRandomAlphanumericString(length: 10)
            ],
            body: jsonData,
            responseType: GeneralPaymentInitilizationResponse.self
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self?.checkoutManager.setStatus(data.status.status.uppercased())
                        self?.checkoutManager.setTransactionId(data.transactionId)
                        self?.actions = CommonFunctions.handle(timeStamp: data.transactionTimestampLocale, reasonCode: data.status.reasonCode, reason: data.status.reason, methodType: "WALLET", response: PaymentActionResponse(action: data.actions), shopperVpa:"")
                    case .failure(let error):
                        let errorDescription = error.localizedDescription.lowercased()

                        if errorDescription.contains("expired") {
                            self?.checkoutManager.setStatus("EXPIRED")
                        } else {
                            self?.checkoutManager.setStatus("FAILED")
                        }

                        self?.actions = CommonFunctions.handle(
                            timeStamp: "",
                            reasonCode: "",
                            reason: error.localizedDescription, // You can pass actual error for better debugging
                            methodType: "",
                            response: PaymentActionResponse(action: nil),
                            shopperVpa: ""
                        )

                        print("=======errorr \(error)")
                    }
                }
            }
    }
}
