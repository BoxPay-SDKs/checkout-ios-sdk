struct PaymentResponse: Codable {
    let status: String?
    let statusReason: String?
    let reasonCode: String?
    let transactionId: String?
    let transactionTimestamp: String?
    let transactionTimestampLocale: String?
    let amount: Double?
    let currencyCode: String?
    let currencySymbol: String?
    let paymentCompleted: Bool?
    let originalAuthAmount: Double?
    let amountLocale: String?
    let totalAmount: Double?
    let paymentMethod: PaymentMethodInfo?
    let order: OrderPaymentResponse?
    let emiMethod: EmiMethodPaymentResponse?  // ✅ Added emiMethod as optional
}

struct PaymentMethodInfo: Codable {
    let id: String?
    let type: String?
    let brand: String?
    let classification: String?
    let subBrand: String?
}

struct OrderPaymentResponse: Codable {
    let voucherCode: String?
    let shippingAmount: Double?
    let taxAmount: Double?
    let originalAmount: Double?
    let totalDiscountedAmount: Double?
    let items: [Item]?
}

struct Item: Codable {
    let id: String?
    let itemName: String?
    let description: String?
    let quantity: Int?
    let manufacturer: String?
    let brand: String?
    let color: String?
    let productUrl: String?
    let imageUrl: String?
    let categories: String?
    let amountWithoutTax: Double?
    let taxAmount: Double?
    let taxPercentage: Double?
    let discountedAmount: Double?
    let timestamp: String?
    let gender: String?
    let size: String?
}

struct EmiMethodPaymentResponse: Codable {
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
    let applicableOffer: ApplicableOfferDetails?  // ✅ Corrected applicableOffer structure
    let logoUrl: String?
    let netAmount: Double?
    let merchantBorneInterestRate: Double?
    let issuerTitle: String?
    let effectiveInterestRate: Double?
}

