//
//  BoxpayCheckout.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//

import SwiftUICore
import SwiftUI

public struct BoxpayCheckout : View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = CheckoutViewModel()
    @StateObject var upiViewModel = UpiViewModel()
    @StateObject var fetchStatusViewModel = FetchStatusViewModel()
    
    @State private var sessionExpireScreen = false
    @State private var sessionCompleteScreen = false
    @State private var sessionFailedScreen = false
    @State private var showTimerSheet = false
    @State private var errorReason = ""
    @State private var timeStamp = ""
    @State private var shopperVpa = ""
    @State private var showCancelPopup = false
    @State private var isUserIntentProcessing = false
    
    @State private var navigateToCardScreen = false
    @State private var navigateToWalletScreen = false
    @State private var navigateToNetBankingScreen = false
    @State private var navigateToBnplScreen = false
    @State private var navigateToEmiScreen = false
    
    @State private var isCheckoutMainScreenFocused = false
    
    public init(
        token: String,
        shopperToken: String,
        configurationOptions: ConfigOptions? = nil,
        onPaymentResult: @escaping (PaymentResultObject) -> Void
    ) {
        let checkoutManager = CheckoutManager.shared
        PaymentCallBackManager.shared.setCallback(onPaymentResult)
        checkoutManager.setBaseURL(configurationOptions?[ConfigurationOption.enableTextEnv] == true)
        checkoutManager.setIsSuccessScreenVisible(configurationOptions?[ConfigurationOption.showBoxpaySuccessScreen] ?? true)
        
        // Set tokens
        if !token.isEmpty {
            checkoutManager.setMainToken(token)
        }
        
        if !shopperToken.isEmpty {
            checkoutManager.setShopperToken(shopperToken)
        }
        
    }
    
    public var body: some View {
        // Replace this with your actual SDK UI
        ZStack {
            if viewModel.isFirstLoad {
                ShimmerPlaceholderScreen()
            } else if upiViewModel.isLoading {
                BoxpayLoaderView()
            } else {
                VStack {
                    HeaderView(
                        text: "Payment Details",
                        showDesc: true,
                        showSecure: true,
                        itemCount: viewModel.itemsCount,
                        currencySymbol: viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "",
                        amount: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "",
                        onBackPress: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    ScrollView {
                        TitleHeaderView(text: "Address")
                        AddressSectionView(address: formattedAddress())
                        if(viewModel.upiIntentMethod || viewModel.upiCollectMethod) {
                            TitleHeaderView(text: "Pay by any UPI")
                                .padding(.bottom, 8)
                        }
                        
                        UpiScreen(isUpiIntentVisible: $viewModel.upiIntentMethod, isGpayVisible: isGooglePayInstalled(), isPaytmVisible: isPaytmInstalled(), isPhonePeVisible: isPhonePeInstalled(), isUpiCollectVisible: $viewModel.upiCollectMethod, handleUpiPayment: upiViewModel.initiateUpiPostRequest)
                        
                        if(viewModel.cardsMethod || viewModel.walletsMethod || viewModel.netBankingMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                            TitleHeaderView(text: "More Payment Options")
                            VStack(spacing: 0) {
                                if(viewModel.cardsMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        // click to navigate to cards screen
                                        navigateToCardScreen = true
                                    }, image: "ic_card", title: "Cards")
                                    if(viewModel.netBankingMethod || viewModel.walletsMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.walletsMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        // click to navigate to wallets screen
                                        navigateToWalletScreen = true
                                    }, image: "ic_wallet", title: "Wallet")
                                    if(viewModel.netBankingMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.netBankingMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        // click to navigate to netbanking screen
                                        navigateToNetBankingScreen = true
                                    }, image: "ic_netBanking", title: "Netbanking")
                                    if(viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.emiMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        // click to navigate to emi screen
                                        navigateToEmiScreen = true
                                    }, image: "ic_emi", title: "EMI")
                                    if(viewModel.bnplMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.bnplMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        // click to navigate to bnpl screen
                                        navigateToBnplScreen = true
                                    }, image: "ic_bnpl", title: "Pay Later")
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color(hex: "#F5F6FB"))
            }
            NavigationLink(destination: CardScreen(isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToCardScreen) {
                        EmptyView()
                    }
            NavigationLink(destination: WalletScreen(isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToWalletScreen) {
                        EmptyView()
                    }
            
            NavigationLink(destination: NetBankingScreen(isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToNetBankingScreen) {
                        EmptyView()
                    }
            NavigationLink(destination: BnplScreen(isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToBnplScreen) {
                        EmptyView()
                    }
            NavigationLink(destination: EmiScreen(isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToEmiScreen) {
                        EmptyView()
                    }
        }
        .onAppear {
            viewModel.getCheckoutSession()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(upiViewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{ $0}, perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.checkoutManager.getBrandColor(),
                onGoBackToHome: {
                    print("Okay from session expire screen")
                    PaymentCallBackManager.shared.triggerPaymentResult(result: PaymentResultObject(status: viewModel.checkoutManager.getStatus(), transactionId: viewModel.checkoutManager.getTransactionId()))
                    sessionExpireScreen = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .bottomSheet (isPresented: $sessionFailedScreen) {
            PaymentFailureScreen(reason: $errorReason, onRetryPayment: {
                sessionFailedScreen = false
            }, onReturnToPaymentOptions: {
                sessionFailedScreen = false
            },brandColor: viewModel.checkoutManager.getBrandColor())
        }
        .bottomSheet(isPresented: $sessionCompleteScreen) {
            GeneralSuccessScreen(transactionID: viewModel.checkoutManager.getTransactionId(), date: CommonFunctions.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: CommonFunctions.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: viewModel.checkoutManager.getTotalAmount(),currencySymbol: viewModel.checkoutManager.getCurrencySymbol(), onDone: {
                sessionCompleteScreen = false
                PaymentCallBackManager.shared.triggerPaymentResult(result: PaymentResultObject(status: viewModel.checkoutManager.getStatus(), transactionId: viewModel.checkoutManager.getTransactionId()))
                presentationMode.wrappedValue.dismiss()
            },brandColor: viewModel.checkoutManager.getBrandColor())
        }
        .bottomSheet(isPresented: $showTimerSheet) {
            UpiTimerSheet(onCancelButton: {
                showCancelPopup = true
            },_vpa: $shopperVpa, brandColor: viewModel.checkoutManager.getBrandColor())
        }
        .overlay(
            Group {
                if showCancelPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .allowsHitTesting(false)

                        CancelPaymentPopup(
                            onCancel: {
                                showCancelPopup = false
                                showTimerSheet = false
                                fetchStatusViewModel.stopFetchingStatus()
                            },
                            onDismiss: {
                                showCancelPopup = false
                            },
                            brandColor: viewModel.checkoutManager.getBrandColor()
                        )
                    }
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("App is now active again!")
            fetchStatusViewModel.startFetchingStatus(methodType: "UpiIntent")
        }
        .onChange(of: isCheckoutMainScreenFocused) { focused in
            if(focused) {
                PaymentCallBackManager.shared.triggerPaymentResult(result: PaymentResultObject(status: viewModel.checkoutManager.getStatus(), transactionId: viewModel.checkoutManager.getTransactionId()))
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func formattedAddress() -> String {
        if let address = viewModel.sessionData?.paymentDetails.shopper.deliveryAddress {
               return "\(address.address1 ?? ""), \(address.address2 ?? ""), \(address.city ?? ""), \(address.state ?? ""), \(address.postalCode ?? "")"
           }
           return ""
       }
    
    private func isGooglePayInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "tez://")!)
    }

    // Check if Paytm is installed
    private func isPaytmInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "paytmmp://")!)
    }

    // Check if PhonePe is installed
    private func isPhonePeInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "phonepe://")!)
    }

    private func handlePaymentAction(_ action: PaymentAction) {
        switch action {
        case .showFailed(let message):
            print("❌ Failed: - \(message)")
            viewModel.checkoutManager.setStatus("FAILED")
            showTimerSheet = false
            upiViewModel.isLoading = false
            fetchStatusViewModel.stopFetchingStatus()
            errorReason = message
            sessionFailedScreen = true
        case .showSuccess(let time):
            print("✅ Success: - \(time)")
            viewModel.checkoutManager.setStatus("SUCCESS")
            showTimerSheet = false
            fetchStatusViewModel.stopFetchingStatus()
            timeStamp = time
            sessionCompleteScreen = true
        case .showExpired:
            print("⌛ Expired:")
            viewModel.checkoutManager.setStatus("EXPIRED")
            showTimerSheet = false
            fetchStatusViewModel.stopFetchingStatus()
            sessionExpireScreen = true
        case .openWebViewUrl(let url):
            print("🌐 WebView URL: \(url)")
        case .openWebViewHTML(let htmlContent):
            print("📄 HTML: \(htmlContent)")
        case .openIntentUrl(let base64Url):
            print("📦 Base64: \(base64Url)")
            upiViewModel.isLoading = true
            openURL(urlString: base64Url)
        case .openUpiTimer(let vpa) :
            print("⌛ timer opened:")
            fetchStatusViewModel.startFetchingStatus(methodType: "UpiCollect")
            shopperVpa = vpa
            showTimerSheet = true
        }
    }
    private func openURL(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                isUserIntentProcessing = true
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL: \(urlString)")
            }
        }
    }

}

private struct AddressSectionView: View {
    let address : String
    var body: some View {
        if(address != ""){
            VStack(alignment: .leading) {
                HStack {
                    Image(frameworkAsset: "map_pin_gray")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                    
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text("Deliver at ")
                                .font(.custom("Poppins-Regular",size: 12))
                                .foregroundColor(Color(hex: "#4F4D55")) +
                            Text("Others")
                                .font(.custom("Poppins-SemiBold", size: 12))
                                .foregroundColor(Color(hex: "#4F4D55"))
                        }
                        Text(address)
                            .font(.custom("Poppins-SemiBold",size: 14))
                            .foregroundColor(Color(hex: "#4F4D55"))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensures full width
                    }
                    
                    Spacer()
                    
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal, 16)
            }
        }
    }
}
