import SwiftUI
import Foundation
import UIKit
import Combine


extension Image {
    // Helper to load images from the framework's assets catalog
    init(frameworkAsset name: String) {
        let bundle = Bundle(for: TestClass.self) // Any class from framework would work
        self.init(name, bundle: bundle)
    }
}

@available(iOS 15.0, *)
public struct MainCheckoutSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    // Access the presentation mode
    @StateObject private var viewModel = CheckoutViewModel()
    @StateObject private var upiIntentViewModel = UPIIntentViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    private let repeatingTask = RepeatingTask()
    let onPaymentResult: (PaymentResultObject) -> Void
    
    
    private let token: String // Token to be passed into the view
    let apiManager = APIManager()
    private var orderItems: [OrderItem] {
        viewModel.sessionData?.paymentDetails.order?.items ?? []
    }
    private var paymentOptionList: [PaymentMethod] {
        viewModel.paymentOptionList
    }
    
    // Booleans for payment method visibility
    @State private var upiAvailable = false
    @State private var upiCollectMethod = false
    @State private var upiIntentMethod = false
    @State private var upiQRMethod = false
    @State private var cardsMethod = false
    @State private var walletMethods = false
    @State private var netBankingMethods = false
    @State private var emiMethod = false
    @State private var bnplMethod = false
    @State private var orderDetailsVisibility = true
    @State private var isUpiIntentProcessing = true // Control loader visibility
    @State private var isPaytmSelected = false
    @State private var isGpaySelected = false
    @State private var isPhonepeSelected = false
    @State private var showSuccessSheet = false
    @State private var showFailureScreen = false
    @State private var showSessionExpireScreen = false
    @State private var willMoveToNextScreen = false
    
    
    let baseUrlProd: String = "https://apis.boxpay.in/"
    let baseUrlSandbox: String = "https://sandbox-apis.boxpay.tech/"
    let baseUrlTest: String = "https://test-apis.boxpay.tech/"
    
    
    // Custom initializer to accept the token
    public init(token: String,baseUrlFlag: Int, onPaymentResult: @escaping (PaymentResultObject) -> Void) {
        self.token = token
        self.onPaymentResult = onPaymentResult
        PaymentCallbackManager.shared.setCallback(onPaymentResult) // Store callback globally
        // Save base url passed by the merchant
        if(baseUrlFlag == 0){
            apiManager.setBaseURL(baseUrlTest)
        }else if(baseUrlFlag == 1){
            apiManager.setBaseURL(baseUrlSandbox)
        }else if(baseUrlFlag == 2){
            apiManager.setBaseURL(baseUrlProd)
        }
        apiManager.setMainToken(token)
    }
    
    // This is dynamic array for populating payment options, we update this later
    var dynamicPaymentOptions: [PaymentOption] {
        PaymentOption.allOptions(
            cardsMethod: cardsMethod,
            walletMethods: walletMethods,
            netBankingMethods: netBankingMethods,
            emiMethod: emiMethod,
            bnplMethod: bnplMethod
        )
    }
    

    private func processPaymentOptions() {
        // updating booleans with enabled payment options
        for paymentMethod in paymentOptionList {
            if paymentMethod.type == "Upi" {
                if paymentMethod.brand == "UpiCollect" {
                    upiCollectMethod = true
                    upiAvailable = true
                }
                if paymentMethod.brand == "UpiIntent" {
                    upiIntentMethod = true
                    upiAvailable = true
                }
                if paymentMethod.brand == "UpiQr" {
                    upiQRMethod = true
                    upiAvailable = true
                }
            }
            if paymentMethod.type == "Card" {
                cardsMethod = true
            }
            if paymentMethod.type == "Wallet" {
                walletMethods = true
            }
            if paymentMethod.type == "Emi" {
                emiMethod = true
            }
            if paymentMethod.type == "BuyNowPayLater" {
                bnplMethod = true
            }
            if paymentMethod.type == "NetBanking" {
                netBankingMethods = true
            }
        }
    }
    
    
    public var body: some View {
        ZStack {
            VStack(spacing: 12) {
                //header
                PaymentHeaderView(
                    title: "Payment Details",
                    itemCount: viewModel.sessionData?.paymentDetails.order?.items.count ?? 0,
                    totalPrice: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                    onBack: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView { // Wrap the entire content inside ScrollView
                    
                    VStack(spacing: 12) {
                        
                        Divider().frame(height: 2)
                        
                        // Address Section
                        let address = viewModel.sessionData?.paymentDetails.shopper.deliveryAddress
                        AddressSectionView(address: address ?? nil)
                        
                        // UPI Section
                        UPIPaymentOptionsView(
                            upiIntentMethod: upiIntentMethod,
                            upiCollectMethod: upiCollectMethod,
                            isGpaySelected: $isGpaySelected,
                            isPhonepeSelected: $isPhonepeSelected,
                            isPaytmSelected: $isPaytmSelected,
                            isUpiIntentProcessing: $isUpiIntentProcessing,
                            showSuccessSheet: $showSuccessSheet,
                            showFailureScreen: $showFailureScreen,
                            upiIntentViewModel: upiIntentViewModel,
                            repeatingTask: repeatingTask
                        )
                        
                        
                        // More Payment Options - Inside a large card
                        VStack(alignment: .leading, spacing: 8) {
                            MorePaymentOptionsView(
                                paymentOptions: dynamicPaymentOptions,
                                handlePaymentOptionTap: handlePaymentOptionTap,
                                willMoveToNextScreen: $willMoveToNextScreen
                            )
                            
                            OrderSummarySectionView(
                                orderDetailsVisibility: $orderDetailsVisibility,
                                orderItems: orderItems,
                                viewModel: viewModel
                            )
                            
                            // Security Footer
                            FooterView()
                        }
                        
                    }.background(Color(UIColor.systemGray6).ignoresSafeArea()).preferredColorScheme(.light)
                        .navigationBarBackButtonHidden(true)
                    
                }.background(Color(UIColor.systemGray6).ignoresSafeArea()).preferredColorScheme(.light)
                    .navigationBarBackButtonHidden(true)
                
                    .onAppear {
                        
                        viewModel.getCheckoutSession(token : token)
                        DismissManager.shared.dismissAction = { dismiss() }
                        repeatingTask.paymentViewModel = paymentViewModel
                        NotificationCenter.default.addObserver(forName: .paymentTimerExpired, object: nil, queue: .main) { _ in
                            showSessionExpireScreen = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            TimerManager.shared.startTimer(duration: 900)
                            self.processPaymentOptions()
                            isUpiIntentProcessing = false
                        }
                    }
                
                // Success Sheet
                    .sheet(isPresented: $showSuccessSheet) {
                        if #available(iOS 16.0, *) {
                            GeneralSuccessScreen(
                                transactionID: paymentViewModel.transactionId,
                                date: paymentViewModel.transactionDate, // Directly access the value
                                time: paymentViewModel.transactionTime, // Directly access the value
                                paymentMethod: paymentViewModel.paymentMethod, // Directly access the value
                                totalAmount: paymentViewModel.totalAmount // Directly access the value
                            ) {
                                let result = PaymentResultObject(status: paymentViewModel.status,transactionId: paymentViewModel.transactionId,operationId: "")
                                
                                // Trigger the callback to pass the result back
                                PaymentCallbackManager.shared.triggerPaymentResult(result: result)
                                showSuccessSheet = false // Close the success screen when "Done" is pressed
                                //completePayment()
                                dismiss()
                            }
                            .presentationDetents([.height(500)]) // Optional: Set height dynamically
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            // Fallback on earlier versions
                        } // Show drag indicator
                    }
                    .sheet(isPresented: $showFailureScreen) {
                        if #available(iOS 16.0, *) {
                            PaymentFailureScreen(
                                onRetryPayment: {
                                    print("Retry Payment action from sheet")
                                    showFailureScreen = false
                                    dismiss()
                                },
                                onReturnToPaymentOptions: {
                                    showFailureScreen = false
                                    print("Return to Payment Options action from sheet")
                                }
                            )
                            .presentationDetents([.height(400)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            
                        }
                    }
                
                    .sheet(isPresented: $showSessionExpireScreen) {
                        if #available(iOS 16.0, *) {
                            SessionExpireScreen(
                                onGoBackToHome: {
                                    print("Okay from session expire screen")
                                    DismissManager.shared.dismiss()
                                    showSessionExpireScreen = false
                                    dismiss()
                                }
                            )
                            .presentationDetents([.height(400)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            
                        }
                    }
            }
            
            if isUpiIntentProcessing { // Check if loader is active
                Color.black.opacity(0.5) // Background overlay
                    .ignoresSafeArea() // Cover the entire screen
                
                VStack { // Loader VStack
                    ProgressView() // Circular loader
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2) // Adjust loader size
                    
                    Text("Loading...") // Loading text
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.top, 10)
                } // End of Loader VStack
            }
        }.navigate(to: AddCardView(), when: $willMoveToNextScreen)
    }
}


struct PaymentHeaderView: View {
    var title: String
    var itemCount: Int
    var totalPrice: String
    var onBack: (() -> Void)?
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 15)
            
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
                .frame(width: 15)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                
                HStack(spacing: 3) {
                    Text("\(itemCount) Items · Total:")
                        .font(.system(size: 12, weight: .regular))
                    Text("₹\(totalPrice)")
                        .font(.system(size: 12, weight: .bold))
                        .underline()
                }
            }
            
            Spacer()
            
            Text("100% SECURE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
                .padding(2)
                .background(Color.gray.opacity(0.2))
            
            Spacer()
                .frame(width: 10)
        }
    }
}


struct MorePaymentOptionsView: View {
    let paymentOptions: [PaymentOption]
    let handlePaymentOptionTap: (PaymentOption) -> Void
    @Binding var willMoveToNextScreen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More Payment Options")
                .font(.system(size: 14, weight: .semibold))
                .padding(.leading)
            
            PaymentOptionsListView(
                paymentOptions: paymentOptions,
                handlePaymentOptionTap: handlePaymentOptionTap,
                willMoveToNextScreen: $willMoveToNextScreen
            )
        }
    }
}


struct OrderSummarySectionView: View {
    @Binding var orderDetailsVisibility: Bool
    let orderItems: [OrderItem]
    let viewModel: CheckoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order Summary")
                .font(.system(size: 14, weight: .semibold))
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Price Details")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text("₹" + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: orderDetailsVisibility ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            orderDetailsVisibility.toggle()
                        }
                }
                
                if orderDetailsVisibility {
                    OrderSummaryView(orderItems: orderItems, viewModel: viewModel)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal)
        }
    }
}


struct AddressSectionView: View {
    let address: DeliveryAddress?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Address")
                .font(.system(size: 14, weight: .semibold))
                .padding(.leading)
            HStack {
                Image(frameworkAsset: "map_pin_gray")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
                    .scaledToFit()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Deliver to")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                        
                    }
                    if let address = address {
                        Text("\(address.address1 ?? ""), \(address.address2 ?? ""), \(address.city ?? ""), \(address.state ?? ""), \(address.postalCode ?? "")")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                    } else {
                        Text("No Address Available")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal)
        }
    }
}



struct UPIPaymentOptionsView: View {
    var upiIntentMethod: Bool
    var upiCollectMethod: Bool
    @Binding var isGpaySelected: Bool
    @Binding var isPhonepeSelected: Bool
    @Binding var isPaytmSelected: Bool
    @Binding var isUpiIntentProcessing: Bool
    @Binding var showSuccessSheet: Bool
    @Binding var showFailureScreen: Bool
    var upiIntentViewModel: UPIIntentViewModel
    var repeatingTask: RepeatingTask
    
    var body: some View {
        if upiIntentMethod || upiCollectMethod {
            VStack(alignment: .leading, spacing: 8) {
                Text(upiIntentMethod && (isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled()) ? "Pay by any UPI App" : "Pay using UPI ID")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    if upiIntentMethod && (isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled()) {
                        HStack(spacing: 10) {
                            UPIAppButton(
                                appName: "GPay",
                                imageName: "gpay_upi_logo",
                                isSelected: $isGpaySelected,
                                otherSelection1: $isPhonepeSelected,
                                otherSelection2: $isPaytmSelected
                            )
                            
                            UPIAppButton(
                                appName: "PhonePe",
                                imageName: "phonepe",
                                isSelected: $isPhonepeSelected,
                                otherSelection1: $isGpaySelected,
                                otherSelection2: $isPaytmSelected
                            )
                            
                            UPIAppButton(
                                appName: "Paytm",
                                imageName: "paytm_upi_logo",
                                isSelected: $isPaytmSelected,
                                otherSelection1: $isGpaySelected,
                                otherSelection2: $isPhonepeSelected
                            )
                            
                            Spacer()
                        }
                        
                        if upiIntentMethod && upiCollectMethod {
                            Spacer()
                            Divider()
                            Spacer().frame(height: 2)
                        }
                    }
                    
                    if isGpaySelected || isPaytmSelected || isPhonepeSelected {
                        Button(action: {
                            let selectedApp = isPaytmSelected ? "PayTm" : isGpaySelected ? "GPay" : "PhonePe"
                            upiIntentViewModel.fetchUPIIntentURL(appName: selectedApp, isLoading: $isUpiIntentProcessing)
                            repeatingTask.startRepeatingTask(showSuccesScreen: $showSuccessSheet, showFailureScreen: $showFailureScreen, repeatingTask: repeatingTask, isLoading: $isUpiIntentProcessing)
                        }) {
                            Text("Proceed to Pay")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isUpiIntentProcessing ? Color.gray : Color.green)
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(isUpiIntentProcessing)
                        .padding(.top, 1)
                    }
                    
                    if upiCollectMethod {
                        HStack {
                            Image(frameworkAsset: "add_green")
                                .foregroundColor(.green)
                            Text("Add new UPI ID")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
            }
        }
    }
}

struct UPIAppButton: View {
    let appName: String
    let imageName: String
    @Binding var isSelected: Bool
    @Binding var otherSelection1: Bool
    @Binding var otherSelection2: Bool
    
    var body: some View {
        VStack {
            Image(frameworkAsset: imageName)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(10)
                .frame(height: 50)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    isSelected = true
                    otherSelection1 = false
                    otherSelection2 = false
                }
            
            Text(appName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
        }
    }
}


struct PaymentOptionsListView: View {
    var paymentOptions: [PaymentOption]
    var handlePaymentOptionTap: (PaymentOption) -> Void
    @Binding var willMoveToNextScreen: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(paymentOptions.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    Button(action: {
                        willMoveToNextScreen = true
                        handlePaymentOptionTap(paymentOptions[index])
                    }) {
                        HStack(alignment: .center) {
                            Image(frameworkAsset: paymentOptions[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20) // Consistent icon size
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(paymentOptions[index].title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                                
                                Text(paymentOptions[index].subTitle)
                                    .font(.system(size: 10, weight: .regular))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle()) // Remove default button styling
                    
                    // Add divider only between rows, not after the last row
                    if index < paymentOptions.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct PriceDetailsView: View {
    @Binding var orderDetailsVisibility: Bool
    var totalAmount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Price Details")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("₹" + totalAmount)
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: orderDetailsVisibility ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        orderDetailsVisibility.toggle()
                    }
            }
        }
    }
}

struct FooterView: View{
    var body: some View {
        HStack {
            Spacer()
            Text("Secured by")
                .font(.system(size: 11, weight: .bold))
            Image(frameworkAsset: "boxpay_logo") // Replace with your asset name
                .resizable()
                .frame(width: 50, height: 30)
            Spacer()
        }
        .padding(.bottom, 16)
        
        Spacer()
    }
}

struct OrderSummaryView: View {
    var orderItems: [OrderItem]
    var viewModel: CheckoutViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Order Items
            VStack {
                if orderItems.isEmpty {
                    Text("Loading items...")
                        .font(.system(size: 14, weight: .regular))
                } else {
                    ItemsListView(items: orderItems)
                }
            }
            .background(Color.white)
            
            // Sub Total
            HStack {
                Text("Sub Total")
                    .font(.system(size: 14, weight: .regular))
                Spacer()
                Text("₹" + (viewModel.sessionData?.paymentDetails.order?.originalAmountLocaleFull ?? "0"))
                    .font(.system(size: 14, weight: .regular))
            }
            
            // Shipping Charges
            HStack {
                Text("Shipping Charges")
                    .font(.system(size: 14, weight: .regular))
                Spacer()
                Text("₹" + (viewModel.sessionData?.paymentDetails.order?.shippingAmountLocaleFull ?? ""))
                    .font(.system(size: 14, weight: .regular))
            }
            
            // Taxes
            HStack {
                Text("Taxes")
                    .font(.system(size: 14, weight: .regular))
                Spacer()
                Text("₹" + (viewModel.sessionData?.paymentDetails.order?.taxAmountLocaleFull ?? ""))
                    .font(.system(size: 14, weight: .regular))
            }
            
            Divider()
            
            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("₹" + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                    .font(.system(size: 14, weight: .bold))
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}

struct PaymentOption: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subTitle: String
    
    // Dynamic property for all options
    static func allOptions(
        cardsMethod: Bool,
        walletMethods: Bool,
        netBankingMethods: Bool,
        emiMethod: Bool,
        bnplMethod: Bool
    ) -> [PaymentOption] {
        var options = [PaymentOption]()
        
        if cardsMethod {
            options.append(PaymentOption(imageName: "card_grey", title: "Cards", subTitle: "Save and pay via cards"))
        }
        if walletMethods {
            options.append(PaymentOption(imageName: "wallet_grey", title: "Wallet", subTitle: "Paytm, GooglePay, PhonePe & more"))
        }
        if netBankingMethods {
            options.append(PaymentOption(imageName: "bank_grey", title: "Netbanking", subTitle: "Select from a list of banks"))
        }
        if emiMethod {
            options.append(PaymentOption(imageName: "emi_grey", title: "EMI", subTitle: "Easy Installments"))
        }
        if bnplMethod {
            options.append(PaymentOption(imageName: "bnpl_grey", title: "Buy Now Pay Later", subTitle: "Save and pay via cards"))
        }
        
        return options
    }
}

func handlePaymentOptionTap(option: PaymentOption) {
    switch option.title {
    case "Cards":
        print("Cards option tapped")
        // Navigate to Cards screen or perform the Cards action
    case "Wallet":
        print("Wallet option tapped")
        // Navigate to Wallet screen or perform the Wallet action
    case "Netbanking":
        print("Netbanking option tapped")
        // Navigate to Netbanking screen or perform the Netbanking action
    case "EMI":
        print("EMI option tapped")
        // Navigate to EMI screen or perform the EMI action
    case "Buy Now Pay Later":
        print("Buy Now Pay Later option tapped")
        // Navigate to BNPL screen or perform the BNPL action
    default:
        print("Unknown option tapped")
    }
}



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


class APIServiceSessionApi {
    
    func getCheckoutSession(token: String, completion: @escaping (Result<CheckoutSession, Error>) -> Void) {
        let apiManager = APIManager()
        let baseUrl = apiManager.getBaseURL() + "v0/checkout/sessions/"
        guard let url = URL(string: baseUrl + token) else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let checkoutSession = try JSONDecoder().decode(CheckoutSession.self, from: data)
                completion(.success(checkoutSession))
            } catch {
                // Print the error for debugging
                print("Decoding error: \(error)")
                // Optionally, print the raw JSON for verification
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }
}


class UPIIntentViewModel: ObservableObject {
    @Published var upiIntentURLBase64: String?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUPIIntentURL(appName: String,isLoading: Binding<Bool>) {
        isLoading.wrappedValue = true
        let apimanager = APIManager()
        let baseURL = apimanager.getBaseURL() // Replace with your API URL
        let token = "v0/checkout/sessions/" + apimanager.getMainToken() // Replace with your token
        guard let url = URL(string: "\(baseURL)\(token)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let requestBody: [String: Any] = [
            "browserData": [
                "screenHeight": "2324",
                "screenWidth": "1080",
                "acceptHeader": "application/json",
                "userAgentHeader": "Mozilla/5.0 (Linux; Android 13; V2055 Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.6778.135 Mobile Safari/537.36",
                "browserLanguage": "en_US",
                "ipAddress": "null",
                "colorDepth": 24,
                "javaEnabled": true,
                "timeZoneOffSet": 330,
                "packageId": "com.boxpay.checkoutdemoapp"
            ],
            "instrumentDetails": [
                "type": "upi/intent",
                "upiAppDetails": [
                    "upiApp": appName
                ]
            ],
            "shopper": [
                "email": "testing@bixpay.com",
                "firstName": "testing",
                "gender": NSNull(), // Use NSNull for null values
                "lastName": "testing_last_name",
                "phoneNumber": "+919999999999",
                "uniqueReference": "x123y"
            ]
        ]
        
        // Convert the body to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            print("jsonDataRequest\(jsonData)")
            request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
            request.addValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
            request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")
            request.httpBody = jsonData
        } catch {
            print("Error serializing request body: \(error.localizedDescription)")
            isLoading.wrappedValue = false
            return
        }
        
        // Log the request body for debugging
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        // Perform the request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("HTTP Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    print("UpiIntentError: \(error)")
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    print("Request finished successfully")
                }
            }, receiveValue: { [weak self] response in
                if let urlForIntent = response.actions.first?.url {
                    let base64URL = urlForIntent.data(using: .utf8)?.base64EncodedString()
                    self?.upiIntentURLBase64 = base64URL
                    print("UPI Intent URL (Base666666): \(urlForIntent)")
                    print("UPI Intent URL (Base64): \(base64URL ?? "Not available")")
                    
                    // Call launchUPIIntent directly here
                    self?.launchUPIIntent(base64URL: urlForIntent)
                } else {
                    self?.errorMessage = "Invalid response structure"
                    print("Invalid response structure: No URL found in actions")
                    isLoading.wrappedValue = false
                }
            }
            )
            .store(in: &cancellables)
    }
    
    struct APIResponse: Codable {
        let actions: [Action]
    }
    
    struct Action: Codable {
        let url: String
    }
    
    func generateRandomAlphanumericString(length: Int) -> String {
        let charPool = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        return String((0..<length).compactMap { _ in charPool.randomElement() })
    }
    
    func launchUPIIntent(base64URL: String) {
        // Step 1: Decode the Base64 string into Data
        guard let decodedData = Data(base64Encoded: base64URL),
              
                // Step 2: Convert the decoded Data into a UTF-8 string
              let urlString = String(data: decodedData, encoding: .utf8),
              
                // Step 3: Convert the string into a URL object
              let uri = URL(string: urlString) else {
            print("Invalid or improperly Base64-decoded UPI URL")
            return
        }
        // Step 5: Ensure the device can handle the URL
        guard UIApplication.shared.canOpenURL(uri) else {
            print("App not available to handle UPI intent: \(uri.absoluteString)")
            return
        }
        
        // Step 6: Launch the app with the decoded URL
        UIApplication.shared.open(uri, options: [:]) { success in
            if success {
                print("UPI app launched successfully with URL: \(uri.absoluteString)")
            } else {
                print("Failure while launching UPI app")
            }
        }
    }
    
    
}



func decodeCheckoutSession(data: Data, completion: @escaping (Result<CheckoutSession, Error>) -> Void) {
    // Try to parse the JSON first
    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        // Convert the dictionary back into `Data` for decoding
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            
            // Decode the `jsonData` into `CheckoutSession`
            let checkoutSession = try decoder.decode(CheckoutSession.self, from: jsonData)
            
            // Pass the result back in the completion handler
            completion(.success(checkoutSession))
        } catch {
            // Handle any errors during decoding
            completion(.failure(error))
        }
    } else {
        // Handle error if JSON is not valid
        completion(.failure(NSError(domain: "Invalid JSON", code: -3, userInfo: nil)))
    }
}



// Item view for order details list
struct OrderItemView: View {
    let item: OrderItem
    
    var body: some View {
        HStack(spacing: 12) { // Adjust spacing for a clean look
            // Load the image
            if #available(iOS 15.0, *) {
                AsyncImage(url: URL(string: item.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(8) // Add padding inside the square
                        .frame(width: 50, height: 50) // Ensure image size fits
                        .background(Color.white) // Background color for padding area
                        .cornerRadius(10) // Rounded corners
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
            } else {
                // Fallback on earlier versions
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
            }
            
            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemName)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(2) // Truncate long names
                    .foregroundColor(.black)
                
                Text("Qty: \(item.quantity)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Price
            Text("₹\(String(format: "%.2f", item.amountWithoutTax + (item.taxAmount)))")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(Color.white)
    }
}

//List setup
struct ItemsListView: View {
    let items: [OrderItem]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    OrderItemView(item: item)
                        .background(Color.white)
                }
            }
            .padding(.horizontal, 0)
        }
        .frame(maxHeight: 200) // Maximum height for the ScrollView
        .background(Color(UIColor.white)) // Light background color
    }
}


// Check if GooglePay is installed
func isGooglePayInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "tez://")!)
}

// Check if Paytm is installed
func isPaytmInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "paytmmp://")!)
}

// Check if PhonePe is installed
func isPhonePeInstalled() -> Bool {
    return UIApplication.shared.canOpenURL(URL(string: "phonepe://")!)
}

// MainCheckoutSheet preview
struct MainSheetPreviewNew: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MainCheckoutSheet(
                token: "qVDnGlSGnC",
                baseUrlFlag: 0,
                onPaymentResult: { result in
                    print("Preview Payment Result: \(result.status)")
                }
            )
        }
    }
}
