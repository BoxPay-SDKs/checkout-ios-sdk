//
//  CheckoutViewModel.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 30/01/25.
//


class CheckoutViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var sessionData: CheckoutSession? {
        didSet {
            if let paymentOptions = sessionData?.configs.paymentMethods, !paymentOptions.isEmpty {
                print("Payment options loaded: \(paymentOptions)")
            }
        }
    }
    @Published var errorMessage: String = "Something Went Wrong"
    
    var paymentOptionList: [PaymentMethod] {
        sessionData?.configs.paymentMethods ?? []
    }
    
    func getCheckoutSession(token: String) {
        isLoading = true
        let apiService = APIServiceSessionApi()
        
        apiService.getCheckoutSession(token: token) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.sessionData = data
                    print("API Response: \(data)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("API Error: \(error)")
                }
            }
        }
    }
    
    
}
