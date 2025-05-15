//
//  CheckoutSession.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


public struct CheckoutSession : Decodable {
    let paymentDetails: PaymentDetails
    let merchantDetails: MerchantDetails
    let configs: Configs
    let status : String?
    let sessionExpiryTimestampLocale : String?
    let lastTransactionId : String?
}

public struct PaymentDetails: Decodable {
    let money: Money
    let shopper: Shopper
    let order: OrderCheckOut?
}
public struct Shopper: Decodable {
    let firstName: String?
    let lastName: String?
    let gender: String?
    let phoneNumber: String?
    let email: String?
    let uniqueReference: String?
    let deliveryAddress: DeliveryAddress?
    let dateOfBirth: String?
    let panNumber: String?
}

public struct Money: Decodable {
    let amount: Double?
    let currencyCode: String?
    let amountLocale: String?
    let amountLocaleFull: String?
    let currencySymbol: String?
}

public struct DeliveryAddress: Decodable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let state: String?
    let countryCode: String?
    let postalCode: String?
    let shopperRef: String?
    let addressRef: String?
    let labelType: String?
    let labelName: String?
    let name: String?
    let email: String?
    let phoneNumber: String?
}

public struct OrderCheckOut: Decodable {
    let items: [OrderItem]?
    let shippingAmountLocaleFull: String?
    let taxAmountLocaleFull: String?
    let originalAmountLocaleFull: String?
}

public struct OrderItem: Identifiable,Decodable {
    public let id: String
    let itemName: String
    let description: String?
    let quantity: Int
    let imageUrl: String
    let amountWithoutTaxLocaleFull: String
    let taxAmountLocaleFull: String?
}

public struct MerchantDetails: Decodable {
    let checkoutTheme: CheckoutTheme
}

public struct CheckoutTheme: Decodable {
    let primaryButtonColor: String?
    let buttonTextColor: String?
}

public struct Configs: Decodable {
    let paymentMethods: [PaymentMethod]
    let enabledFields: [EnabledField]
}

public struct PaymentMethod: Decodable {
    let id: String?
    let type: String?
    let brand: String?
    let title: String?
    let logoUrl: String?
    let instrumentTypeValue: String?
    let applicableOffers: [ApplicableOffer]? // Updated to handle both cases
    let emiMethod: EmiMethod?
}

public struct EmiMethod: Decodable {
    let brand: String?
    let issuer: String?
    let duration: Int?
    let processingFee: ProcessingFee?
    let logoUrl: String?
    let issuerTitle: String?
    let effectiveInterestRate: Double?
    let merchantBorneInterestRate : Double?
    let emiAmountLocaleFull: String?
    let totalAmountLocaleFull: String?
    let interestChargedAmountLocaleFull: String?
    let bankChargedInterestAmountLocaleFull: String?
    let merchantBorneInterestAmountLocaleFull: String?
    let netAmountLocaleFull: String?
    let cardlessEmiProvider: String?
    let cardlessEmiProviderTitle: String?
    let cardlessEmiProviderValue: String?
}

public struct ProcessingFee: Decodable {
    let amountLocaleFull: String?
}

public struct ApplicableOffer: Decodable {
    let code: String?
    let discount: DiscountDetails?
}

public struct DiscountDetails: Decodable {
    let type: String?
}

public struct EnabledField: Decodable {
    let field: String?
    let editable: Bool
    let mandatory: Bool
}
