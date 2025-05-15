//
//  BnplScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore
import SwiftUI

struct BnplScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isCheckoutFocused : Bool

    @StateObject private var viewModel = BnplViewModel()
    @State private var selectedInstrumentValue: String = ""
    
    @StateObject var fetchStatusViewModel = FetchStatusViewModel()
    
    @State private var sessionExpireScreen = false
    @State private var sessionCompleteScreen = false
    @State private var sessionFailedScreen = false
    @State private var errorReason = ""
    @State private var timeStamp = ""
    @State private var paymentUrl : String? = nil
    @State private var paymentHtmlString: String? = nil
    @State private var showWebView = false
    
    
    var body: some View {
        ZStack {
            if viewModel.isFirstLoad {
                ShimmerPlaceholderScreen()
            } else if viewModel.isLoading {
                BoxpayLoaderView()
            } else {
                VStack(alignment: .leading) {
                    VStack {
                        HeaderView(
                            text: "Select BNPL",
                            showDesc: true,
                            showSecure: true,
                            itemCount: viewModel.checkoutManager.getItemsCount(),
                            currencySymbol: viewModel.checkoutManager.getCurrencySymbol(),
                            amount: viewModel.checkoutManager.getTotalAmount(),
                            onBackPress: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                    }
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            if(viewModel.bnplDataClass.isEmpty) {
                                VStack(alignment: .center, spacing: 16){
                                    Image(frameworkAsset: "ic_search_not_found", isTemplate: false)
                                        .frame(width: 60, height: 60)
                                    Text("Oops!! No results found")
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                        .foregroundColor(Color(hex: "#212426"))
                                    Text("Please try another search")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(Color(hex: "#4F4D55"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 300) // Set your desired limited height here
                                .frame(maxHeight: .infinity, alignment: .center)
                            } else {
                                ForEach(Array(viewModel.bnplDataClass.enumerated()), id: \.element.id) { index, item in
                                    PaymentOptionView(
                                        isSelected: selectedInstrumentValue == item.instrumentTypeValue,
                                        imageUrl: item.image,
                                        title: item.title,
                                        currencySymbol: viewModel.checkoutManager.getCurrencySymbol(),
                                        amount: viewModel.checkoutManager.getTotalAmount(),
                                        instrumentValue: item.instrumentTypeValue,
                                        brandColor: viewModel.checkoutManager.getBrandColor(),
                                        onClick: { string in
                                            selectedInstrumentValue = string
                                        },
                                        onProceedButton: {
                                            viewModel.initiateBnplPostRequest(instrumentValue: selectedInstrumentValue)
                                        },
                                        fallbackImage: "ic_bnpl_semi_bold"
                                    )
                                    if index < viewModel.bnplDataClass.count - 1 {
                                            Divider()// Remove extra padding around Divider
                                        }
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                .background(Color(hex: "#F5F6FB"))
            }
        }
        .onAppear {
            viewModel.getBnplPaymentMethods()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.checkoutManager.getBrandColor(),
                onGoBackToHome: {
                    print("Okay from session expire screen")
                    isCheckoutFocused = true
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
                isCheckoutFocused = true
                presentationMode.wrappedValue.dismiss()
            },brandColor: viewModel.checkoutManager.getBrandColor())
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: URL(string: paymentUrl ?? ""), htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    viewModel.isLoading = true
                    fetchStatusViewModel.startFetchingStatus(methodType: "Wallet")
                }
            )
        }
    }
    
    private func handlePaymentAction(_ action: PaymentAction) {
        switch action {
        case .showFailed(let message):
            print("❌ Failed: - \(message)")
            viewModel.isLoading = false
            viewModel.checkoutManager.setStatus("FAILED")
            fetchStatusViewModel.stopFetchingStatus()
            errorReason = message
            sessionFailedScreen = true
        case .showSuccess(let time):
            print("✅ Success: - \(time)")
            viewModel.checkoutManager.setStatus("SUCCESS")
            viewModel.isLoading = false
            fetchStatusViewModel.stopFetchingStatus()
            timeStamp = time
            sessionCompleteScreen = true
        case .showExpired:
            print("⌛ Expired:")
            viewModel.checkoutManager.setStatus("EXPIRED")
            fetchStatusViewModel.stopFetchingStatus()
            sessionExpireScreen = true
        case .openWebViewUrl(let url):
            print("🌐 WebView URL: \(url)")
            paymentUrl = url
            showWebView = true
        case .openWebViewHTML(let htmlContent):
            print("📄 HTML: \(htmlContent)")
            paymentHtmlString = htmlContent
            showWebView = true
        case .openIntentUrl(let base64Url):
            print("📦 Base64: \(base64Url)")
        case .openUpiTimer(_) :
            print("⌛ timer opened:")
        }
    }
}
