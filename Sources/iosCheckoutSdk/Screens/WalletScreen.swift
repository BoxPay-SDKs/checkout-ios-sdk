//
//  WalletScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI


struct WalletScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isCheckoutFocused : Bool

    @StateObject private var viewModel = WalletViewModel()
    
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()
    @State private var searchTextField: String = ""
    @State private var isSearchTextFieldFocused: Bool = false
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
                            text: "Choose Wallet",
                            showDesc: true,
                            showSecure: true,
                            itemCount: viewModel.itemsCount,
                            currencySymbol: viewModel.currencySymbol,
                            amount: viewModel.totalAmount,
                            onBackPress: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        FloatingLabelTextField(placeholder: "Search for wallet", text: $searchTextField, isValid: .constant(true), onChange : { newText in
                            searchTextField = newText
                            filterWallets(matching: newText)
                        },isFocused: $isSearchTextFieldFocused, trailingIcon: .constant(""), leadingIcon: .constant("ic_search"), isSecureText: .constant(false))
                            .frame(height: 40)
                            .padding(16)
                    }
                    .background(Color.white)
                    
                    Text("Your Linked Wallets")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#020815").opacity(0.71))
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                    
                    ScrollView {
                        if(viewModel.walletDataClass.isEmpty) {
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
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        } else {
                            PaymentOptionView(
                                items: $viewModel.walletDataClass,
                                onProceed: { instrumentValue , _ , _ in
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "WalletScreen", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "WalletScreen", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "WalletScreen", "")
                                    viewModel.initiateWalletPostRequest(instrumentValue: instrumentValue)
                                },
                                showLastUsed: false
                            )
                            .commonCardStyle()
                        }
                    }
                }
                .background(Color(hex: "#F5F6FB"))
            }
        }
        .onAppear {
            viewModel.getWalletPaymentMethods()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.brandColor,
                onGoBackToHome: {
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
            },brandColor: viewModel.brandColor)
        }
        .bottomSheet(isPresented: $sessionCompleteScreen) {
            GeneralSuccessScreen(transactionID: viewModel.transactionId, date: StringUtils.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: StringUtils.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: viewModel.totalAmount,currencySymbol: viewModel.currencySymbol, onDone: {
                sessionCompleteScreen = false
                isCheckoutFocused = true
                presentationMode.wrappedValue.dismiss()
            },brandColor: viewModel.brandColor)
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: paymentUrl,
                htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    viewModel.isLoading = true
                    fetchStatusViewModel.startFetchingStatus(methodType: "Wallet")
                }
            )
        }
    }
    
    private func handlePaymentAction(_ action: PaymentAction) {
        Task {
            switch action {
            case .showFailed(let message):
                viewModel.isLoading = false
                await viewModel.checkoutManager.setStatus("FAILED")
                fetchStatusViewModel.stopFetchingStatus()
                errorReason = message
                sessionFailedScreen = true
            case .showSuccess(let time):
                await viewModel.checkoutManager.setStatus("SUCCESS")
                viewModel.isLoading = false
                fetchStatusViewModel.stopFetchingStatus()
                timeStamp = time
                sessionCompleteScreen = true
            case .showExpired:
                await viewModel.checkoutManager.setStatus("EXPIRED")
                fetchStatusViewModel.stopFetchingStatus()
                sessionExpireScreen = true
            case .openWebViewUrl(let url):
                paymentUrl = url
                showWebView = true
            case .openWebViewHTML(let htmlContent):
                paymentHtmlString = htmlContent
                showWebView = true
            case .openIntentUrl(_):
                // no operation
                break
            case .openUpiTimer(_) :
                // no operation
                break
            case .openQRUrl(url: let url):
                // no operation
                break
            }
        }
    }
    
    func filterWallets(matching text: String) {
        selectedInstrumentValue = ""
        if(text.isEmpty) {
            viewModel.walletDataClass = viewModel.defaultWalletDataClass
            return
        }
        let list = viewModel.defaultWalletDataClass
        let lowercasedText = text.lowercased()

        viewModel.walletDataClass = list.filter { item in
            let words = item.displayName.lowercased().split(separator: " ") // Split into words
                return words.contains { word in
                    word.hasPrefix(lowercasedText)
                }
            }
        }
}
