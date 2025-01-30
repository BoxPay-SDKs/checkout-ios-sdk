//
//  CheckoutSessionResponse.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 09/01/25.
//
import Foundation

// MARK: - Root struct
public struct CheckoutSession: Codable {
    let token: String?
    let title: String?
    let productName: String?
    let description: String?
    let callerType: String?
    let merchantId: String?
    let paymentDetails: PaymentDetails
    let merchantDetails: MerchantDetails
    let configs: Configs
    let sessionExpiryTimestamp: String?
    let lastPaidAtTimestamp: String? // Made optional
    let lastTransactionId: String?  // Made optional
    let status: String?
    let anyTransactionSuccessful: Bool
    let multipleTransactionSupported: Bool
    let lastTransactionDetails: LastTransactionDetails? // Made optional
    let sessionExpiryTimestampLocale: String?
    let lastPaidAtTimestampLocale: String?
}

// MARK: - PaymentDetails struct
public struct PaymentDetails: Codable {
    let context: ContextModel
    let money: Money
    let onDemandAmount: Bool
    let frontendReturnUrl: String?
    let frontendBackUrl: String?
    let billingAddress: String?
    let shopper: Shopper
    let order: OrderCheckOut?
    let product: String?
    let subscriptionDetails: String?
}

// MARK: - Context struct
public struct ContextModel: Codable {
    let legalEntity: LegalEntity
    let countryCode: String?
    let localeCode: String?
    let clientPosId: String?
    let orderId: String?
    let clientOrgIP: String?
}

// MARK: - LegalEntity struct
public struct LegalEntity: Codable {
    let code: String?
}

// MARK: - Money struct
public struct Money: Codable {
    let amount: Double
    let currencyCode: String?
    let amountLocale: String?
    let amountLocaleFull: String?
    let currencySymbol: String?
}

// MARK: - Shopper struct
public struct Shopper: Codable {
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

// MARK: - DeliveryAddress struct
public struct DeliveryAddress: Codable {
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

// MARK: - Order struct
public struct OrderCheckOut: Codable {
    let voucherCode: String?
    let shippingAmount: Double
    let taxAmount: Double
    let originalAmount: Double
    let totalDiscountedAmount: Double?
    let items: [OrderItem]
    let shippingAmountLocale: String?
    let shippingAmountLocaleFull: String?
    let taxAmountLocale: String?
    let taxAmountLocaleFull: String?
    let originalAmountLocale: String?
    let originalAmountLocaleFull: String?
}

// MARK: - OrderItem struct
public struct OrderItem: Identifiable,Codable {
    public let id: String?
    let itemName: String
    let description: String
    let quantity: Int
    let manufacturer: String?
    let brand: String?
    let color: String?
    let productUrl: String?
    let imageUrl: String
    let categories: [String]?
    let amountWithoutTax: Double
    let taxAmount: Double
    let taxPercentage: Double?
    let discountedAmount: Double?
    let timestamp: String?
    let gender: String?
    let size: String?
    let amountWithoutTaxLocale: String?
    let amountWithoutTaxLocaleFull: String
    let taxAmountLocale: String?
    let taxAmountLocaleFull: String?
}

// MARK: - MerchantDetails struct
public struct MerchantDetails: Codable {
    let merchantName: String?
    let logoUrl: String?
    let checkoutTheme: CheckoutTheme
    let timeZone: String?
    let locale: String?
    let template: String?
    let customFields: [CustomField]?
    let convenienceFeeChargedToShopper: Bool
}

public struct CustomField: Codable {
    let fieldName: String
}

// MARK: - CheckoutTheme struct
public struct CheckoutTheme: Codable {
    let headerColor: String?
    let primaryButtonColor: String?
    let secondaryButtonColor: String?
    let headerTextColor: String?
    let buttonTextColor: String?
    let buttonShape: String?
    let buttonContent: String?
    let font: String?
}

// MARK: - Configs struct
public struct Configs: Codable {
    let paymentMethods: [PaymentMethod]
    let additionalFieldSets: [String]
    let enabledFields: [EnabledField]
    let referrers: [String]?
}

// MARK: - PaymentMethod struct
public struct PaymentMethod: Codable, Hashable {
    let id: String?
    let type: String?
    let brand: String?
    let title: String?
    let typeTitle: String?
    let logoUrl: String?
    let instrumentTypeValue: String?
    let applicableOffers: [ApplicableOffer]? // Updated to handle both cases
    let emiMethod: EmiMethod?
}

public enum ApplicableOffer: Codable, Hashable {
    case string(String)
    case object(ApplicableOfferDetails)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let objectValue = try? container.decode(ApplicableOfferDetails.self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.typeMismatch(ApplicableOffer.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected String or ApplicableOfferDetails"
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .object(let objectValue):
            try container.encode(objectValue)
        }
    }
}

public struct ApplicableOfferDetails: Codable, Hashable {
    let title: String?
    let description: String?
    let terms: String?
    let type: String?
    let code: String?
    let discount: DiscountDetails?
}

public struct DiscountDetails: Codable, Hashable {
    let percentage: Int?
    let amount: Int?
    let type: String?
    let maxAmount: Int?
}


// Define the EmiMethod struct
public struct EmiMethod: Codable, Hashable {
    let brand: String?
    let issuer: String?
    let duration: Int?
    let interestRate: Double?
    let minAmount: Double?
    let merchantPayback: String?
    let subvention: String?
    let processingFee: ProcessingFee?
    let emiAmount: Double?
    let totalAmount: Double?
    let interestChargedAmount: Double?
    let bankChargedInterestAmount: Double?
    let merchantBorneInterestAmount: Double?
    let logoUrl: String?
    let netAmount: Double?
    let merchantBorneInterestRate: Double?
    let issuerTitle: String?
    let effectiveInterestRate: Double?
    let minAmountLocale: String?
    let minAmountLocaleFull: String?
    let emiAmountLocale: String?
    let emiAmountLocaleFull: String?
    let totalAmountLocale: String?
    let totalAmountLocaleFull: String?
    let interestChargedAmountLocale: String?
    let interestChargedAmountLocaleFull: String?
    let bankChargedInterestAmountLocale: String?
    let bankChargedInterestAmountLocaleFull: String?
    let merchantBorneInterestAmountLocale: String?
    let merchantBorneInterestAmountLocaleFull: String?
    let netAmountLocale: String?
    let netAmountLocaleFull: String?
}

// Define the ProcessingFee struct
public struct ProcessingFee: Codable, Hashable {
    let feeType: String?
    let percentage: Double?
    let amount: Double?
    let amountLocale: String?
    let amountLocaleFull: String?
}


// MARK: - EnabledField struct
public struct EnabledField: Codable {
    let field: String?
    let editable: Bool
    let mandatory: Bool
}

// MARK: - LastTransactionDetails struct
public struct LastTransactionDetails: Codable {
    let timestamp: String?
    let transactionId: String?
    let status: TransactionStatus?
    let money: Money?
    let additionalChargeAmount: String?
    let authDccQuotationDetails: String?
    let originalAuthAmount: Double?
    let offers: [String]?
    let paymentMethod: PaymentMethod?
    let emiMethod: String?
    let pending: Bool?
    let timestampLocale: String?
    let originalAuthAmountLocale: String?
    let originalAuthAmountLocaleFull: String?
}

// MARK: - TransactionStatus struct
public struct TransactionStatus: Codable {
    let operation: String?
    let status: String?
    let reason: String?
    let reasonCode: String?
}
