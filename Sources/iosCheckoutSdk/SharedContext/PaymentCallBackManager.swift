//
//  PaymentCallBackManager.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

@MainActor
public class PaymentCallBackManager {
    
    static let shared = PaymentCallBackManager()
    private var paymentCallback: ((PaymentResultObject) -> Void)?
    
    private init() {}
    
    func setCallback(_ callback: @escaping (PaymentResultObject) -> Void) {
        self.paymentCallback = callback
    }
    
    func triggerPaymentResult(result: PaymentResultObject) {
        paymentCallback?(result)
    }
}
