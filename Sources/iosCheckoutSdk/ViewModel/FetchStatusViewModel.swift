import Foundation
import UIKit
import Combine

@MainActor
class FetchStatusViewModel: ObservableObject {
    @Published var actions: PaymentAction?
    let apiManager = ApiService.shared
    let checkoutManager = CheckoutManager.shared

    private var timer: Timer?
    
    func startFetchingStatus(methodType: String) {
        // Schedule timer to run every 4 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchStatus(methodType: methodType)
            }
        }
    }

    func stopFetchingStatus() {
        timer?.invalidate()
        timer = nil
    }

    private func fetchStatus(methodType: String) async {
        do {
            let data: FetchStatusResponse = try await apiManager.request(
                endpoint: "status",
                responseType: FetchStatusResponse.self
            )
            
            print("=======data \(data)")
            await checkoutManager.setStatus(data.status.uppercased())
            await checkoutManager.setTransactionId(data.transactionId ?? "")
            actions = await GlobalUtils.handle(
                timeStamp: data.transactionTimestampLocale ?? "",
                reasonCode: data.reasonCode ?? "",
                reason: data.statusReason ?? "",
                methodType: methodType,
                response: PaymentActionResponse(action: nil),
                shopperVpa: ""
            )
        } catch {
            let errorDescription = error.localizedDescription.lowercased()
            if errorDescription.contains("expired") {
                await checkoutManager.setStatus("EXPIRED")
            } else {
                await checkoutManager.setStatus("FAILED")
            }
            
            actions = await GlobalUtils.handle(
                timeStamp: "",
                reasonCode: "",
                reason: error.localizedDescription,
                methodType: "",
                response: PaymentActionResponse(action: nil),
                shopperVpa: ""
            )
            print("=======errorr \(error)")
        }
    }
}
