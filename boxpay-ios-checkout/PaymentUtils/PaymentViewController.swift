//
//  PaymentViewController.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 29/01/25.
//


import UIKit

class PaymentViewController: UIViewController, PaymentResultDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        PaymentCallbackManager.shared.setDelegate(self)
    }

    func onPaymentResult(result: PaymentResultObject) {
        print("Payment Status: \(result.status)")
        DispatchQueue.main.async {
            // Handle UI updates
            self.dismiss(animated: true)
        }
    }
}
