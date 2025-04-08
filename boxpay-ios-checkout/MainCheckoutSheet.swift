import SwiftUI
import Foundation
import UIKit
import Combine
import AlertToast


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
    @StateObject private var upiCollectViewModel = UpiCollectViewmodel()
    @StateObject private var recommendedInstrumentViewModel = RecommendedInstrumentationViewModel()
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
    
    private var totalAmountValue: String{
        viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"
    }
    private var currencySymbol: String{
        viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
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
    @State private var orderDetailsVisibility = false
    @State private var isUpiIntentProcessing = true // Control loader visibility
    @State private var isPaytmSelected = false
    @State private var isGpaySelected = false
    @State private var isPhonepeSelected = false
    @State private var showSuccessSheet = false
    @State private var showFailureScreen = false
    @State private var showSessionExpireScreen = false
    @State private var showQuickPayModal = false
    @State private var moveToCardsPaymentScreen = false
    @State private var moveToWalletPaymentScreen = false
    @State private var moveToNetBankingScreen = false
    @State private var moveToBNPLScreen = false
    @State private var moveToEMIOptionsScreen = false
    @State private var upiCollectExpanded = false
    @State private var showUpiTimerSheet = false
    @State private var showUpiTimerSheetOpened = false
    @State private var isRecurringPaymentExpanded = true
    
    @State private var upiID: String = ""
    @State private var countryCode: String = ""
    @State private var merchantId: String = ""
    @State private var legalEntity: String = ""
    @State private var shopperToken: String = ""
    @State private var status: String = "PENDING"
    @State private var isFocused: Bool = false
    @State private var saveForFuture: Bool = false
    @State private var isUPIValid: Bool = false
    @State private var dynamicAmount: Double = 1500.00
    @State private var showCancelDialog = false
    @State var selectedInstrument: RecommendedPaymentInstrument?
    // Timer state
    @State private var timeRemaining: Int = 300 // 5 minutes in seconds
    @State private var progress: CGFloat = 1.0
    @State private var items: [RecommendedPaymentInstrument]? = []
    
    
    
    let baseUrlProd: String = "https://apis.boxpay.in/"
    let baseUrlSandbox: String = "https://sandbox-apis.boxpay.tech/"
    let baseUrlTest: String = "https://test-apis.boxpay.tech/"
    
    
    // Custom initializer to accept the token
    public init(token: String, shopperToken : String ,baseUrlFlag: Int, onPaymentResult: @escaping (PaymentResultObject) -> Void) {
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
        if(!token.isEmpty){
            apiManager.setMainToken(token)
        }
        if(!shopperToken.isEmpty){
            apiManager.setShopperToken(shopperToken)
            self.shopperToken = shopperToken
            
        }
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
                    itemCount: viewModel.sessionData?.paymentDetails.order?.items?.count ?? 0,
                    totalPrice: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                    currencySymbol: currencySymbol,
                    onBack: {
                        showCancelDialog = true
                    }
                )
                
                ScrollView { // Wrap the entire content inside ScrollView
                    
                    VStack(spacing: 12) {
                        
                        Divider().frame(height: 2)
                        
                        // Address Section
                        let address = viewModel.sessionData?.paymentDetails.shopper.deliveryAddress
                        AddressSectionView(address: address ?? nil)
                        
                        
                        RecommendedUpiSection(items: items ?? [],upiCollectViewModel: upiCollectViewModel, selectedInstrument: $selectedInstrument,showSuccessSheet: $showSuccessSheet,showFailureScreen: $showFailureScreen, showUpiTimerSheet: $showUpiTimerSheet, isUpiIntentProcessing: $isUpiIntentProcessing,repeatingTask: repeatingTask, totalAmountValue: totalAmountValue, upiID : $upiID)
                        
                        
                        
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
                            showUpiTimerSheet: $showUpiTimerSheet,
                            upiIntentViewModel: upiIntentViewModel,
                            upiCollectViewModel: upiCollectViewModel,
                            viewModel: viewModel,
                            repeatingTask: repeatingTask,
                            upiID: $upiID,
                            isFocused: $isFocused,
                            saveForFuture: $saveForFuture,
                            upiCollectExpanded: $upiCollectExpanded, isUPIValid: $isUPIValid,
                            dynamicAmount: dynamicAmount,
                            legalEntity: legalEntity,
                            merchantId: merchantId,
                            countryCode: countryCode,
                            totalAmountValue : totalAmountValue
                        )
                        
                        
                        // More Payment Options - Inside a large card
                        VStack(alignment: .leading, spacing: 8) {
                            if(cardsMethod || walletMethods || netBankingMethods || emiMethod || bnplMethod){
                                MorePaymentOptionsView(
                                    paymentOptions: dynamicPaymentOptions,
                                    handlePaymentOptionTap: handlePaymentOptionTap,
                                    moveToCardsPaymentScreen: $moveToCardsPaymentScreen, moveToWalletPaymentScreen: $moveToWalletPaymentScreen,moveToBNPLScreen: $moveToBNPLScreen,moveToNetBankingScreen: $moveToNetBankingScreen,moveToEMIOptionsScreen: $moveToEMIOptionsScreen,
                                    upiIntentMethod: upiIntentMethod,
                                    upiCollectMethod: upiCollectMethod
                                )
                            }
                            OrderSummarySectionView(
                                orderDetailsVisibility: $orderDetailsVisibility,
                                orderItems: orderItems,
                                viewModel: viewModel,
                                totalAmount: totalAmountValue
                            )
                            if(!(viewModel.sessionData?.paymentDetails.subscriptionDetails == nil && viewModel.sessionData?.paymentDetails.subscriptionDetails?.billingCycle.billingTimeUnit == nil)){
                                RecurringPaymentCardView(isExpanded: $isRecurringPaymentExpanded, viewModel: viewModel)
                                
                            }
                            
                            // Security Footer
                            FooterView()
                        }
                        
                    }.background(Color(UIColor.systemGray6).ignoresSafeArea()).preferredColorScheme(.light)
                        .navigationBarBackButtonHidden(true)
                    
                }.background(Color(UIColor.systemGray6).ignoresSafeArea()).preferredColorScheme(.light)
                    .navigationBarBackButtonHidden(true)
                
                    .onAppear {
                        
                        viewModel.getCheckoutSession(token : token)
                        DismissManager.shared.register("MainCheckoutSheet") {
                            dismiss()
                            print("MainScreenDismissed")
                        }
                        repeatingTask.paymentViewModel = paymentViewModel
                        NotificationCenter.default.addObserver(forName: .paymentTimerExpired, object: nil, queue: .main) { _ in
                            showSessionExpireScreen = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            recommendedInstrumentViewModel.fetchRecommendedInstruments(token: token, shopperToken: apiManager.getShopperToken(), shopperReference : viewModel.sessionData?.paymentDetails.shopper.deliveryAddress?.shopperRef ?? "")
                            
                            items = recommendedInstrumentViewModel.recommendedInstruments
                            TimerManager.shared.startTimer(duration: 900)
                            dynamicAmount = viewModel.sessionData?.paymentDetails.money.amount ?? 0
                            countryCode = viewModel.sessionData?.paymentDetails.context.countryCode ?? ""
                            merchantId = viewModel.sessionData?.merchantId ?? ""
                            legalEntity = viewModel.sessionData?.paymentDetails.context.legalEntity.code ?? ""
                            status = viewModel.sessionData?.status ?? "PENDING"
                            
                            if(status == "FAILED" || status == "EXPIRED"){
                                showSessionExpireScreen = true
                            }
                            self.processPaymentOptions()
                            isUpiIntentProcessing = false
                        }
                    }
                    .onDisappear {
                        repeatingTask.stopRepeatingTask()
                    }
                    .onReceive(recommendedInstrumentViewModel.$recommendedInstruments) { newInstruments in
                        items = newInstruments
                        if(!(items?.isEmpty ?? true)){
                            showQuickPayModal = true
                        }
                        print("✅ Updated items: \(items?.map { $0.displayValue ?? "N/A" } ?? [])")
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
                                repeatingTask.stopRepeatingTask()
                                showUpiTimerSheet = false
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
                            PaymentFailureScreen(transactionID: paymentViewModel.transactionId, reasonCode: paymentViewModel.reasonCode, reason: paymentViewModel.statusReason,
                                                 onRetryPayment: {
                                print("Retry Payment action from sheet")
                                showFailureScreen = false
                                showUpiTimerSheet = false
                                repeatingTask.stopRepeatingTask()
                                //dismiss()
                            },
                                                 onReturnToPaymentOptions: {
                                showFailureScreen = false
                                showUpiTimerSheet = false
                                repeatingTask.stopRepeatingTask()
                                print("Return to Payment Options action from sheet")
                            }
                            )
                            .presentationDetents([.height(400)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            
                        }
                    }
                
                    .sheet(isPresented: $showUpiTimerSheet) {
                        if #available(iOS 16.0, *) {
                            UpiTimerSheet(
                                vpa: $upiID,
                                timeRemaining: $timeRemaining,
                                progress: $progress,
                                onCancelButton: {
                                    showCancelDialog = true
                                    // Temporarily close the sheet
                                    showUpiTimerSheet = false
                                }
                            )
                            .presentationDetents([.height(450)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .onAppear {
                                showUpiTimerSheetOpened = true // ✅ Set when sheet appears
                            }
                        } else {
                            // Fallback for earlier iOS versions
                        }
                    }
                    .onDisappear {
                        repeatingTask.stopRepeatingTask()
                    }
                
                    .sheet(isPresented: $showSessionExpireScreen) {
                        if #available(iOS 16.0, *) {
                            SessionExpireScreen(
                                onGoBackToHome: {
                                    print("Okay from session expire screen")
                                    DismissManager.shared.dismissAll()
                                    showUpiTimerSheet = false
                                    showSessionExpireScreen = false
                                    dismiss()
                                }
                            )
                            .presentationDetents([.height(320)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            
                        }
                    }
                    .sheet(isPresented: $showQuickPayModal) {
                        if #available(iOS 16.0, *) {
                            PaymentModalView(price: totalAmountValue, selectedPaymentMethod : items?.first?.value ?? "", onPressOtherOptions: {
                                showQuickPayModal = false
                            }, onProceedToPay: {
                                showQuickPayModal = false
                                showUpiTimerSheet = true
                                upiID = items?.first?.value ?? ""
                                repeatingTask.startRepeatingTask(
                                    showSuccesScreen: $showSuccessSheet,
                                    showFailureScreen: $showFailureScreen,
                                    isLoading: $isUpiIntentProcessing
                                )
                                upiCollectViewModel.initializeUpiCollectPayment(dynamicshopperVpa: items?.first?.value ?? "") { result in
                                    switch result {
                                    case .success(let response):
                                        print("Transaction ID: \(response.transactionId)")
                                        print("Status: \(response.status.status)")
                                        // Handle success
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                        // Handle error
                                    }
                                }
                            })
                            .presentationDetents([.height(230)])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                        } else {
                            
                        }
                    }
                    .toast(isPresenting: $isUpiIntentProcessing, duration: 100, tapToDismiss: false, alert: {
                        AlertToast(type: .loading)
                        //AlertToast goes here it should be here
                    }, onTap: {
                        //onTap would call either if `tapToDismis` is true/false
                        //If tapToDismiss is true, onTap would call and then dismis the alert
                    }, completion: {
                        isUpiIntentProcessing = false
                        //Completion block after dismiss
                    })
            }
            
            if showCancelDialog {
                Color.black.opacity(0.4) // ✅ Background overlay
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showCancelDialog = false
                        if(showUpiTimerSheetOpened){
                            showUpiTimerSheet = true
                        }
                    } // Dismiss on tap
                
                CustomDialogView(
                    title: "Are you sure you want to cancel payment?",
                    message: "This payment request cancels only if you haven't finished the payment",
                    option1: "Yes, cancel", option2: "No",
                    onYes: {
                        print("Yes Clicked")
                        showCancelDialog = false
                        showUpiTimerSheet = false
                        if(showUpiTimerSheetOpened){
                            repeatingTask.stopRepeatingTask()
                        }
                        dismiss()
                    },
                    onNo: {
                        print("No Clicked")
                        if(showUpiTimerSheetOpened){
                            showUpiTimerSheet = true
                        }
                        showCancelDialog = false
                    }
                )
            }
            
        }.navigate(to: AddCardView(), when: $moveToCardsPaymentScreen)
            .navigate(to: WalletPaymentScreen(), when: $moveToWalletPaymentScreen)
            .navigate(to: NetBankingScreen(), when: $moveToNetBankingScreen)
            .navigate(to: BNPLPaymentScreen(), when: $moveToBNPLScreen)
            .navigate(to: EMIOptionsView(), when: $moveToEMIOptionsScreen)
    }
    
    
    struct MorePaymentOptionsView: View {
        let paymentOptions: [PaymentOption]
        let handlePaymentOptionTap: (PaymentOption) -> Void
        @Binding var moveToCardsPaymentScreen: Bool
        @Binding var moveToWalletPaymentScreen: Bool
        @Binding var moveToBNPLScreen: Bool
        @Binding var moveToNetBankingScreen: Bool
        @Binding var moveToEMIOptionsScreen: Bool
        var upiIntentMethod: Bool
        var upiCollectMethod: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if(upiCollectMethod || upiIntentMethod){
                    Text("More Payment Options")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.leading)
                }
                PaymentOptionsListView(
                    paymentOptions: paymentOptions,
                    handlePaymentOptionTap: handlePaymentOptionTap,
                    moveToCardsPaymentScreen: $moveToCardsPaymentScreen, moveToWalletPaymentScreen: $moveToWalletPaymentScreen, moveToBNPLScreen: $moveToBNPLScreen,moveToNetBankingScreen: $moveToNetBankingScreen,moveToEMIOptionsScreen: $moveToEMIOptionsScreen
                )
            }
        }
    }
    
}


struct OrderSummarySectionView: View {
    @Binding var orderDetailsVisibility: Bool
    let orderItems: [OrderItem]
    let viewModel: CheckoutViewModel
    let totalAmount: String
    
    
    var currencySymbol: String {
        viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order Summary")
                .font(.system(size: 14, weight: .semibold))
                .padding(.leading)
            
            if(viewModel.sessionData?.paymentDetails.subscriptionDetails == nil && viewModel.sessionData?.paymentDetails.subscriptionDetails?.billingCycle.billingTimeUnit == nil){
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Price Details")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text(currencySymbol + totalAmount)
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: orderDetailsVisibility ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle()) // Expands tap area to the full row
                    .onTapGesture {
                        withAnimation { orderDetailsVisibility.toggle() }
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
}


struct AddressSectionView: View {
    let address: DeliveryAddress?
    
    var body: some View {
        if(formattedAddress() != ""){
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
                    
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text("Deliver to")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.black)
                        }
                        Text(formattedAddress())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensures full width
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: .infinity) // Ensures HStack takes full width
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
            }
        }
    }
    
    private func formattedAddress() -> String {
        if let address = address {
            return "\(address.address1 ?? ""), \(address.address2 ?? ""), \(address.city ?? ""), \(address.state ?? ""), \(address.postalCode ?? "")"
        }
        return ""
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
    @Binding var showUpiTimerSheet: Bool
    var upiIntentViewModel: UPIIntentViewModel
    var upiCollectViewModel: UpiCollectViewmodel
    let viewModel: CheckoutViewModel
    var repeatingTask: RepeatingTask
    @Binding var upiID: String
    @Binding var isFocused: Bool
    @Binding var saveForFuture: Bool
    @Binding var upiCollectExpanded: Bool
    @Binding var isUPIValid: Bool
    let dynamicAmount: Double
    let legalEntity: String
    let merchantId: String
    let countryCode: String
    let totalAmountValue: String
    
    var currencySymbol: String {
        viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
    }
    
    var body: some View {
        if upiIntentMethod || upiCollectMethod {
            
            upiHeaderView
            
            VStack(alignment: .leading, spacing: 0) {
                
                if upiIntentMethod {
                    upiAppButtonsView
                }
                
                if isGpaySelected || isPaytmSelected || isPhonepeSelected {
                    payNowButton
                }
                
                if (upiIntentMethod && upiCollectMethod  && (isPaytmInstalled() || isGooglePayInstalled() || isPhonePeInstalled())){
                    Divider().padding(.top, 15)
                }
                
                if upiCollectMethod {
                    upiCollectSection
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal)
        }
    }
    
    /// ✅ UPI Header
    private var upiHeaderView: some View {
        HStack(spacing: 1) {
            Text(upiIntentMethod && isAnyUPIAppInstalled ? "Pay by any UPI App" : "Pay using UPI ID")
                .font(.system(size: 14, weight: .semibold))
            
            Image(frameworkAsset: "upi_bhim_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Left align the contents
        .padding(.leading, 20)
    }
    
    /// ✅ UPI Apps Selection Buttons
    private var upiAppButtonsView: some View {
        VStack {
            HStack(spacing: 10) {
                if isGooglePayInstalled() {
                    UPIAppButton(
                        appName: "GPay",
                        imageName: "gpay_upi_logo",
                        isSelected: $isGpaySelected,
                        otherSelection1: $isPhonepeSelected,
                        otherSelection2: $isPaytmSelected,
                        upiCollectExpanded: $upiCollectExpanded
                    )
                }
                
                if isPhonePeInstalled() {
                    UPIAppButton(
                        appName: "PhonePe",
                        imageName: "phonepe",
                        isSelected: $isPhonepeSelected,
                        otherSelection1: $isGpaySelected,
                        otherSelection2: $isPaytmSelected,
                        upiCollectExpanded: $upiCollectExpanded
                    )
                }
                
                if isPaytmInstalled() {
                    UPIAppButton(
                        appName: "Paytm",
                        imageName: "paytm_upi_logo",
                        isSelected: $isPaytmSelected,
                        otherSelection1: $isGpaySelected,
                        otherSelection2: $isPhonepeSelected,
                        upiCollectExpanded: $upiCollectExpanded
                    )
                }
                
                Spacer()
            }
            
        }.padding(.top, (upiIntentMethod && (isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled())) ? 8 : 0)
            .padding(.leading,15)
            .padding(.trailing,15)
    }
    
    /// ✅ Pay Now Button for UPI Apps
    private var payNowButton: some View {
        Button(action: {
            let selectedApp = isPaytmSelected ? "PayTm" : isGpaySelected ? "GPay" : "PhonePe"
            upiIntentViewModel.fetchUPIIntentURL(appName: selectedApp, isLoading: $isUpiIntentProcessing)
            repeatingTask.startRepeatingTask(
                showSuccesScreen: $showSuccessSheet,
                showFailureScreen: $showFailureScreen,
                isLoading: $isUpiIntentProcessing
            )
        }) {
            Text("Pay \(currencySymbol)\(totalAmountValue) via \(selectedUPIApp)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isUpiIntentProcessing ? Color(hex: "#E6E6E6") : Color.green)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .disabled(isUpiIntentProcessing)
        .padding(.top, 6)
        .padding(.leading,15)
        .padding(.trailing,15)
    }
    
    /// ✅ UPI Collect Section
    private var upiCollectSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(frameworkAsset: upiCollectExpanded ? "add_upi_id_opened" : "add_upi_id_closed") // ✅ Change image based on condition
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 55) // ✅ Take full width
            }
            .onTapGesture {
                toggleUPICollect()
            }
            
            if upiCollectExpanded {
                UPIPaymentView(
                    upiID: $upiID,
                    isFocused: $isFocused,
                    saveForFuture: $saveForFuture,
                    isUPIValid: $isUPIValid,
                    currencySymbol: currencySymbol,
                    amount: dynamicAmount,
                    onPay: handleUPIPay
                )
            }
        }
    }
    
    
    /// ✅ Helper Function: Handles UPI Payment
    private func handleUPIPay() {
        dismissKeyboard()
        showUpiTimerSheet = true
        repeatingTask.startRepeatingTask(
            showSuccesScreen: $showSuccessSheet,
            showFailureScreen: $showFailureScreen,
            isLoading: $isUpiIntentProcessing
        )
        upiCollectViewModel.validateVpa(
            userVPA: upiID,
            legalEntity: legalEntity,
            merchantId: merchantId,
            countryCode: countryCode
        )
    }
    
    /// ✅ Helper Function: Toggles UPI Collect Section
    private func toggleUPICollect() {
        upiCollectExpanded.toggle()
        isGpaySelected = false
        isPaytmSelected = false
        isPhonepeSelected = false
    }
    
    /// ✅ Computed Property: Selected UPI App
    private var selectedUPIApp: String {
        isPaytmSelected ? "PayTm" : isGpaySelected ? "GPay" : "PhonePe"
    }
    
    /// ✅ Computed Property: Check if Any UPI App is Installed
    private var isAnyUPIAppInstalled: Bool {
        isGooglePayInstalled() || isPaytmInstalled() || isPhonePeInstalled()
    }
    
    /// ✅ Computed Property: Determines Padding for UPI Collect Toggle
    private var shouldAddPadding: Bool {
        upiIntentMethod && isAnyUPIAppInstalled
    }
}


struct UPIAppButton: View {
    let appName: String
    let imageName: String
    @Binding var isSelected: Bool
    @Binding var otherSelection1: Bool
    @Binding var otherSelection2: Bool
    @Binding var upiCollectExpanded: Bool
    
    var body: some View {
        VStack {
            Image(frameworkAsset: imageName)
                .resizable()
                .scaledToFit() // ✅ Ensures aspect ratio is maintained
                .frame(width: 40, height: 40) // ✅ Restricts max size to 40x40
                .padding(10)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    isSelected.toggle()
                    otherSelection1 = false
                    otherSelection2 = false
                    upiCollectExpanded = false
                }
            
            Text(appName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)
        }
    }
}
struct UPIPaymentView: View {
    @Binding var upiID: String
    @Binding var isFocused: Bool
    @Binding var saveForFuture: Bool
    @Binding var isUPIValid: Bool  // Added binding for isUPIValid
    let currencySymbol: String
    let amount: Double  // Dynamic amount
    let onPay: () -> Void // Callback when button is tapped
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Pass isUPIValid to UPITextField
            UPITextField(upiID: $upiID, isFocused: $isFocused, isUPIValid: $isUPIValid)
            SaveUPIOption(saveForFuture: $saveForFuture)
            
            // Pass isUPIValid to VerifyAndPayButton to enable/disable it based on validation
            VerifyAndPayButton(amount: amount, onPay: onPay, isUPIValid: isUPIValid, currencySymbol: currencySymbol)
        }
    }
}





// MARK: - UPI Text Field
struct UPITextField: View {
    @Binding var upiID: String
    @Binding var isFocused: Bool
    @Binding var isUPIValid: Bool
    
    // Regex pattern for validating UPI ID (example: name@upi)
    private let upiIDPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]{3,}$"
    private var isValidUPI: Bool {
        let regex = try! NSRegularExpression(pattern: upiIDPattern)
        let range = NSRange(location: 0, length: upiID.utf16.count)
        return regex.firstMatch(in: upiID, options: [], range: range) != nil
    }
    
    private var isTextLongEnoughForValidation: Bool {
        if let atIndex = upiID.firstIndex(of: "@") {
            let substringAfterAt = upiID[upiID.index(after: atIndex)...]
            return substringAfterAt.count >= 2
        }
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            TextField("UPI ID", text: $upiID, onEditingChanged: { editing in
                isFocused = editing
            })
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isUPIValid ? Color.green : (upiID.isEmpty ?  Color(hex: "#E6E6E6") : Color.red), lineWidth: 1)
            )
            .font(.system(size: 16))
            .autocapitalization(.none)
            .onChange(of: upiID) { _ in
                isUPIValid = isValidUPI
            }
            
            if(!isUPIValid && isFocused && isTextLongEnoughForValidation){
                Text("Please enter a valid UPI Id")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.leading, 5)
                    .foregroundColor(Color(hex: "#E12121"))
                    .lineLimit(1)
            }
        }.padding(.top, 10)
            .padding(.leading,15)
            .padding(.trailing,15)
    }
}

// MARK: - Save UPI Option
struct SaveUPIOption: View {
    @Binding var saveForFuture: Bool
    
    var body: some View {
        HStack {
            Image(systemName: saveForFuture ? "checkmark.square.fill" : "square")
                .foregroundColor(saveForFuture ? .green : .gray)
                .onTapGesture {
                    saveForFuture.toggle()
                }
            
            Text("Save UPI ID for future usage")
                .font(.system(size: 14))
                .foregroundColor(.black)
        }
        .padding(.leading,15)
        .padding(.trailing,15)
    }
}

// MARK: - Verify & Pay Button
struct VerifyAndPayButton: View {
    let amount: Double
    let onPay: () -> Void
    let isUPIValid: Bool
    let currencySymbol: String
    
    var formattedAmount: String {
        // Check if the amount is a whole number
        if amount == Double(Int(amount)) {
            return String(format: "%.0f", amount) // Remove decimals if whole number
        } else {
            return String(format: "%.2f", amount) // Keep two decimal places
        }
    }
    
    var body: some View {
        Button(action: onPay) {
            Text("Verify & Pay \(currencySymbol) " + formattedAmount)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isUPIValid ? Color.white : Color(hex: "#ADACB0"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isUPIValid ? Color.green : Color(hex: "#E6E6E6"))
                .cornerRadius(8)
        }
        .padding(.top, 2)
        .padding(.bottom, 15)
        .padding(.leading,15)
        .padding(.trailing,15)
        .disabled(!isUPIValid)
    }
}





struct PaymentOptionsListView: View {
    var paymentOptions: [PaymentOption]
    var handlePaymentOptionTap: (PaymentOption) -> Void
    @Binding var moveToCardsPaymentScreen: Bool
    @Binding var moveToWalletPaymentScreen: Bool
    @Binding var moveToBNPLScreen: Bool
    @Binding var moveToNetBankingScreen: Bool
    @Binding var moveToEMIOptionsScreen: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(paymentOptions.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    Button(action: {
                        if(paymentOptions[index].title == "Cards"){
                            moveToCardsPaymentScreen = true
                        }else if(paymentOptions[index].title == "Wallet"){
                            moveToWalletPaymentScreen = true
                        }else if(paymentOptions[index].title == "Netbanking"){
                            moveToNetBankingScreen = true
                        }else if(paymentOptions[index].title == "Buy Now Pay Later"){
                            moveToBNPLScreen = true
                        }else if(paymentOptions[index].title == "EMI"){
                            moveToEMIOptionsScreen = true
                        }
                        handlePaymentOptionTap(paymentOptions[index])
                    }) {
                        HStack(alignment: .center) {
                            Image(frameworkAsset: paymentOptions[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20) // Consistent icon size
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(paymentOptions[index].title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
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


struct OrderSummaryView: View {
    var orderItems: [OrderItem]
    var viewModel: CheckoutViewModel
    var currencySymbol: String {
        viewModel.sessionData?.paymentDetails.money.currencySymbol ?? ""
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Order Items
            VStack {
                if !orderItems.isEmpty {
                    ItemsListView(items: orderItems, currencySymbol: currencySymbol)
                }
            }
            .background(Color.white)
            
            // Sub Total
            // Sub Total
            if let subTotal = viewModel.sessionData?.paymentDetails.order?.originalAmountLocaleFull,
               !subTotal.isEmpty, subTotal != "0" {
                HStack {
                    Text("Sub Total")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                    Text(currencySymbol + subTotal)
                        .font(.system(size: 14, weight: .regular))
                }
                .padding(.bottom, 1)
                .padding(.top, 5)
            }
            
            // Shipping Charges
            if let shipping = viewModel.sessionData?.paymentDetails.order?.shippingAmountLocaleFull,
               !shipping.isEmpty, shipping != "0" {
                HStack {
                    Text("Shipping Charges")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                    Text(currencySymbol + shipping)
                        .font(.system(size: 14, weight: .regular))
                }
                .padding(.bottom, 1)
            }
            
            // Taxes
            if let tax = viewModel.sessionData?.paymentDetails.order?.taxAmountLocaleFull,
               !tax.isEmpty, tax != "0" {
                HStack {
                    Text("Taxes")
                        .font(.system(size: 14, weight: .regular))
                    Spacer()
                    Text(currencySymbol + tax)
                        .font(.system(size: 14, weight: .regular))
                }
            }
            
            Divider()
            
            // Total (Always shown)
            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text(currencySymbol + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
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




// Item view for order details list
struct OrderItemView: View {
    let item: OrderItem
    let currencySymbol: String
    
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
            Text("\(currencySymbol)\(String(format: "%.2f", (item.amountWithoutTax ?? 0) + (item.taxAmount ?? 0)))")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(Color.white)
    }
}


struct RecurringPaymentCardView: View {
    @Binding var isExpanded: Bool
    @ObservedObject var viewModel: CheckoutViewModel
    
    var title: String = "Price Details"
    
    // Extracted values from subscription details
    var subscriptionDetails: SubscriptionDetails? {
        viewModel.sessionData?.paymentDetails.subscriptionDetails
    }
    
    var planName: String? {
        subscriptionDetails?.type.isEmpty == false ? subscriptionDetails?.type : nil
    }
    
    var frequency: String? {
        subscriptionDetails?.billingCycle.billingTimeUnit.isEmpty == false ? subscriptionDetails?.billingCycle.billingTimeUnit : nil
    }
    
    var nextPaymentDate: String? {
        subscriptionDetails?.nextBillingDateLocale.isEmpty == false ? subscriptionDetails?.nextBillingDateLocale : nil
    }
    
    var planExpiryDate: String? {
        subscriptionDetails?.expiryDateLocale.isEmpty == false ? subscriptionDetails?.expiryDateLocale : nil
    }
    
    var currencySymbol: String {
        viewModel.sessionData?.paymentDetails.money.currencySymbol ?? ""
    }
    
    var recurringAmount: String? {
        guard let amount = viewModel.sessionData?.paymentDetails.money.amount, amount != 0.00 else { return nil }
        return currencySymbol + String(format: "%.2f", amount) // Formats to 2 decimal places
    }
    
    var subTotal: String? {
        guard let amount = viewModel.sessionData?.paymentDetails.order?.originalAmountLocaleFull, !amount.isEmpty else { return nil }
        return "\(currencySymbol)\(amount)"
    }
    
    var tax: String? {
        guard let amount = viewModel.sessionData?.paymentDetails.order?.taxAmountLocaleFull, !amount.isEmpty else { return nil }
        return "\(currencySymbol)\(amount)"
    }
    
    var discount: String? {
        guard let amount = viewModel.sessionData?.paymentDetails.order?.totalDiscountedAmount, amount > 0 else { return nil }
        return "-\(currencySymbol)\(amount)"
    }
    
    var shipping: String? {
        guard let amount = viewModel.sessionData?.paymentDetails.order?.shippingAmountLocaleFull, !amount.isEmpty else { return nil }
        return "\(currencySymbol)\(amount)"
    }
    
    var totalAmount: String {
        currencySymbol + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title & Chevron Toggle (Always Visible)
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(totalAmount)
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        withAnimation { isExpanded.toggle() }
                    }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical)
            
            // Expandable Section (Only Visible When Expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // ✅ Show only if plan name exists
                    if let planName = planName {
                        Text(planName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#2D2B32"))
                    }
                    
                    // ✅ Show only if values exist
                    if let frequency = frequency { infoRow(label: "Product Frequency:", value: frequency) }
                    var nextPaymentDateFormatted: String? {
                        formatDate(viewModel.sessionData?.paymentDetails.subscriptionDetails?.nextBillingDateLocale)
                    }
                    
                    var planExpiryDateFormatted: String? {
                        formatDate(viewModel.sessionData?.paymentDetails.subscriptionDetails?.expiryDateLocale)
                    }
                    
                    // ✅ Recurring Amount (Only if value exists)
                    if let recurringAmount = recurringAmount {
                        Text("· You will be charged \(recurringAmount) on the next payment date")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#010102"))
                            .padding(.top, 5)
                    }
                    
                    Divider()
                    
                    // ✅ Show only if values exist
                    if let subTotal = subTotal { infoRow(label: "Sub Total", value: subTotal) }
                    if let tax = tax { infoRow(label: "Taxes", value: tax) }
                    if let discount = discount { infoRow(label: "Discount", value: discount, textColor: Color.green) }
                    if let shipping = shipping { infoRow(label: "Shipping", value: shipping) }
                    
                    // ✅ Total Amount Section
                    HStack {
                        Text("Total")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text(totalAmount)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal, 15) // Reduced padding
    }
    
    // ✅ Row Component for displaying key-value pairs (Only shows if non-empty)
    private func infoRow(label: String, value: String, textColor: Color = Color.black) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#010102"))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textColor)
        }
    }
    
    private func formatDate(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss zzz" // Format of input date
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistency
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MMM-yyyy" // Desired format
            return outputFormatter.string(from: date)
        }
        
        return nil // Return nil if parsing fails
    }
}


//List setup
struct ItemsListView: View {
    let items: [OrderItem]
    let currencySymbol: String
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    OrderItemView(item: item,currencySymbol: currencySymbol)
                        .background(Color.white)
                }
            }
            .padding(.horizontal, 0)
        }
        .frame(maxHeight: 200) // Maximum height for the ScrollView
        .background(Color(UIColor.white)) // Light background color
    }
}

struct RecommendedUpiSection: View {
    let items: [RecommendedPaymentInstrument]
    var upiCollectViewModel: UpiCollectViewmodel
    @Binding var selectedInstrument: RecommendedPaymentInstrument?
    @Binding var showSuccessSheet: Bool
    @Binding var showFailureScreen: Bool
    @Binding var showUpiTimerSheet: Bool
    @Binding var isUpiIntentProcessing: Bool
    var repeatingTask: RepeatingTask
    var totalAmountValue : String
    @Binding var upiID : String
    
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Recommended")
                        .font(.system(size: 14, weight: .semibold))
                }
                RecommendedUpiListView(items: items, upiCollectViewModel: upiCollectViewModel, selectedInstrument: $selectedInstrument, showSuccessSheet: $showSuccessSheet,showFailureScreen: $showFailureScreen, showUpiTimerSheet: $showUpiTimerSheet, isUpiIntentProcessing: $isUpiIntentProcessing, repeatingTask: repeatingTask, totalAmountValue : totalAmountValue, upiID : $upiID)
                    .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct RecommendedUpiListView: View {
    let items: [RecommendedPaymentInstrument]
    var upiCollectViewModel: UpiCollectViewmodel
    @Binding var selectedInstrument: RecommendedPaymentInstrument?
    @Binding var showSuccessSheet: Bool
    @Binding var showFailureScreen: Bool
    @Binding var showUpiTimerSheet: Bool
    @Binding var isUpiIntentProcessing: Bool
    var repeatingTask: RepeatingTask
    var totalAmountValue : String
    @Binding var upiID : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(items.prefix(2).enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 0) {
                            PaymentInstrumentRow(
                                item: item,
                                selectedInstrument: $selectedInstrument,
                                showLastUsed: index == 0 // ✅ Show "Last Used" only on the first item
                            )
                            
                            if selectedInstrument == item {
                                Button(action: {
                                    print("Proceeding with \(item.value ?? "")")
                                    initializePayment(item: item)
                                    
                                }) {
                                    Text("Proceed to Pay ₹" + totalAmountValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                        .background(selectedInstrument == item ? Color.green.opacity(0.1) : Color.clear)
                        
                        if item != items.prefix(2).last {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .background(Color.white)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func initializePayment(item : RecommendedPaymentInstrument){
        
        dismissKeyboard()
        showUpiTimerSheet = true
        repeatingTask.startRepeatingTask(
            showSuccesScreen: $showSuccessSheet,
            showFailureScreen: $showFailureScreen,
            isLoading: $isUpiIntentProcessing
        )
        upiID = item.value ?? ""
        upiCollectViewModel.initializeUpiCollectPayment(dynamicshopperVpa: item.value ?? "") { result in
            switch result {
            case .success(let response):
                print("Transaction ID: \(response.transactionId)")
                print("Status: \(response.status.status)")
                // Handle success
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle error
            }
        }
    }
    
}

struct PaymentInstrumentRow: View {
    let item: RecommendedPaymentInstrument
    @Binding var selectedInstrument: RecommendedPaymentInstrument?
    let showLastUsed: Bool
    
    var body: some View {
        Button(action: {
            selectedInstrument = item
        }) {
            
                HStack {
                    Image(frameworkAsset: "upi_logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                        .padding(.leading, 15)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.value ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#4F4D55"))
                            .padding(.leading, 5)
                        
                        // ✅ Show "Last Used" tag only on the first item
                        if showLastUsed {
                            Text("Last Used")
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.1)) // ✅ Pink background
                                .foregroundColor(.pink)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.pink, lineWidth: 1)
                                )
                                .padding(.leading, 5)
                        }
                        
                    }
                    
                    
                    Spacer()
                    
                    Image(systemName: selectedInstrument == item ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(selectedInstrument == item ? .green : .gray)
                        .font(.system(size: 22))
                        .padding(.trailing, 15)
                }
                .padding(.top, 15)
                .contentShape(Rectangle())
                .padding(.bottom, 15)
            
        }
        .buttonStyle(PlainButtonStyle())
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


struct PaymentHeaderView: View {
    var title: String
    var itemCount: Int
    var totalPrice: String
    var currencySymbol: String
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
                    if(itemCount > 0){
                        Text("\(itemCount) Items ·")
                            .foregroundColor(Color(hex: "#4F4D55"))
                            .font(.system(size: 12, weight: .regular))
                    }
                    Text("Total: " + currencySymbol + "\(totalPrice)")
                        .font(.system(size: 12, weight: .bold))
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
        }.padding(.bottom,5)
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
                token: "a8102cb2-f937-44cc-9469-15f3f864b273",
                shopperToken: "",
                baseUrlFlag: 0,
                onPaymentResult: { result in
                    print("Preview Payment Result: \(result.status)")
                }
            )
        }
    }
}
