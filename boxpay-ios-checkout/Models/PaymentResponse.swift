struct PaymentResponse: Codable {
    let status: String?
    let statusReason: String?
    let reasonCode: String?
    let transactionId: String?
    let transactionTimestamp: String?
    let transactionTimestampLocale: String?
    let amount: Int?
    let currencyCode: String?
    let currencySymbol: String?
    let paymentCompleted: Bool?
    let originalAuthAmount: Int?
    let amountLocale: String?
    let totalAmount: Int?
    let paymentMethod: PaymentMethodInfo?
    let order: OrderPaymentResponse?
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
    let shippingAmount: Int?
    let taxAmount: Double?
    let originalAmount: Int?
    let totalDiscountedAmount: Int?
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
