//
//  FetchStatusViewModel.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import Foundation
import UIKit
import Combine

@MainActor
class FetchStatusViewModel: ObservableObject {
    @Published var actions: PaymentAction?
    let apiManager = ApiService.shared
    let checkoutManager = CheckoutManager.shared

    private var timer: AnyCancellable?

    func startFetchingStatus(methodType:String) {
        // Start timer to fetch status every 4 seconds
        timer = Timer
            .publish(every: 4.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchStatus(methodType: methodType)
            }
    }

    func stopFetchingStatus() {
        // Stop the timer when not needed
        timer?.cancel()
        timer = nil
    }

    private func fetchStatus(methodType:String) {
        apiManager.request(
            endpoint: "status",
            responseType: FetchStatusResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("=======data \(data)")
                    self?.checkoutManager.setStatus(data.status.uppercased())
                    self?.checkoutManager.setTransactionId(data.transactionId ?? "")
                    self?.actions = CommonFunctions.handle(
                        timeStamp: data.transactionTimestampLocale ?? "",
                        reasonCode: data.reasonCode ?? "",
                        reason: data.statusReason ?? "",
                        methodType: methodType,
                        response: PaymentActionResponse(action: nil),
                        shopperVpa:""
                    )
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
