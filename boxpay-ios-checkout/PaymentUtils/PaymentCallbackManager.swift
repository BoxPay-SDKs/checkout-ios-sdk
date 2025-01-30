//
//  PaymentCallbackManager.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 29/01/25.
//

class PaymentCallbackManager {
    static let shared = PaymentCallbackManager()
    
    private var delegate: PaymentResultDelegate?
    private var paymentCallback: ((PaymentResultObject) -> Void)?
    
    private init() {}
    
    // Set the delegate
    func setDelegate(_ delegate: PaymentResultDelegate) {
        self.delegate = delegate
    }
    
    // Set the callback closure
    func setCallback(_ callback: @escaping (PaymentResultObject) -> Void) {
        self.paymentCallback = callback
    }
    
    // Trigger the delegate method if available
    func triggerPaymentResultUsingDelegate(result: PaymentResultObject) {
        delegate?.onPaymentResult(result: result)
    }
    
    // Trigger the callback closure if available
    func triggerPaymentResult(result: PaymentResultObject) {
        paymentCallback?(result)
    }
}



