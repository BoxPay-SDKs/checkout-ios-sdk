//
//  MainCheckoutScreen.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/07/25.
//

import SwiftUI
import Combine


struct MainCheckoutScreen : View {
    @ObservedObject var viewModel: CheckoutViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()

    @Binding var isCheckoutMainScreenFocused : Bool
    
    @ObservedObject private var upiViewModel: UpiViewModel = UpiViewModel()
    @ObservedObject private var fetchStatusViewModel: FetchStatusViewModel = FetchStatusViewModel()
    
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
    @State private var navigateToAddressScreen = false
    @State private var navigateToSavedAddressScreen = false
        
    @State private var paymentUrl : String? = nil
    @State private var paymentHtmlString: String? = nil
    @State private var showWebView = false
    
    @State private var status : String = ""
    @State private var transactionId : String = ""
    
    @State private var timerCancellable: AnyCancellable?

    
    var body: some View {
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
                            isCheckoutMainScreenFocused = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    ScrollView {
                        if viewModel.isShippingEnabled || viewModel.isFullNameEnabled || viewModel.isMobileNumberEnabled || viewModel.isEmailIdEnabled {
                            TitleHeaderView(text: viewModel.isShippingEnabled ? "Address" : "Personal Details")
                            AddressSectionView(
                                onClick:{
                                    if ((viewModel.shopperTokenSaved?.isEmpty) == false) {
                                        navigateToSavedAddressScreen = true
                                    } else {
                                        navigateToAddressScreen = true
                                    }
                                }
                            )
                        }
                        if (!viewModel.recommendedIds.isEmpty) {
                            TitleHeaderView(text: "Recommended")
                                .padding(.bottom, 8)
                            PaymentOptionView(
                                items: $viewModel.recommendedIds,
                                onProceed: { instrumentValue, displayName, paymentType in
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "RecommendedUPI", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "RecommendedUPI", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "RecommendedUPI", "")
                                    upiViewModel.initiateUpiPostRequest(nil , displayName , instrumentValue , paymentType)
                                },
                                showLastUsed: true
                            )
                            .commonCardStyle()
                        }
                        
                        if(viewModel.upiIntentMethod || viewModel.upiCollectMethod) {
                            TitleHeaderView(text: "Pay by any UPI")
                                .padding(.bottom, 8)
                            UpiScreen(
                                handleUpiPayment: upiViewModel.initiateUpiPostRequest,
                                handleQRPayment : upiViewModel.initiateUpiQRPostRequest,
                                savedUpiIds: $viewModel.savedUpiIds,
                                viewModel : upiViewModel,
                                isUpiIntentVisible: $viewModel.upiIntentMethod,
                                isUpiCollectVisible: $viewModel.upiCollectMethod,
                                isUPIQRVisible : $viewModel.upiQrMethod,
                                qrUrl : $upiViewModel.qrUrl,
                                timerCancellable : $timerCancellable
                            )
                        }

                        if(viewModel.cardsMethod && !viewModel.savedCards.isEmpty) {
                            TitleHeaderView(text: "Credit & Debit Cards")
                            SavedCardsComponent(
                                savedItems : $viewModel.savedCards,
                                onProceedButton : { instrumentValue in
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "SavedCards", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "SavedCards", "")
                                    analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "SavedCards", "")
                                    upiViewModel.initiateUpiPostRequest(nil, nil, instrumentValue, "card")
                                },
                                onClickAddNewCard : {
                                    navigateToCardScreen = true
                                }
                            )
                        }
                        
                        if(viewModel.cardsMethod || viewModel.walletsMethod || viewModel.netBankingMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                            TitleHeaderView(text: "More Payment Options")
                            VStack(spacing: 0) {
                                if(viewModel.cardsMethod && viewModel.savedCards.isEmpty) {
                                    MorePaymentContainer(
                                        handleButtonClick: {
                                            timerCancellable?.cancel()
                                            upiViewModel.resetCollect()
                                            navigateToCardScreen = true
                                        },
                                        image: "ic_card",
                                        title: "Cards"
                                    )
                                    if(viewModel.netBankingMethod || viewModel.walletsMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.walletsMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        timerCancellable?.cancel()
                                        upiViewModel.resetCollect()
                                        navigateToWalletScreen = true
                                    }, image: "ic_wallet", title: "Wallet")
                                    if(viewModel.netBankingMethod || viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.netBankingMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        timerCancellable?.cancel()
                                        upiViewModel.resetCollect()
                                        navigateToNetBankingScreen = true
                                    }, image: "ic_netBanking", title: "Netbanking")
                                    if(viewModel.bnplMethod || viewModel.emiMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.emiMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        timerCancellable?.cancel()
                                        upiViewModel.resetCollect()
                                        navigateToEmiScreen = true
                                    }, image: "ic_emi", title: "EMI")
                                    if(viewModel.bnplMethod) {
                                        Divider()
                                    }
                                }
                                if(viewModel.bnplMethod) {
                                    MorePaymentContainer(handleButtonClick: {
                                        timerCancellable?.cancel()
                                        upiViewModel.resetCollect()
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
            NavigationLink(destination: AddAddressScreen(), isActive: $navigateToAddressScreen) {
                        EmptyView()
                    }
            NavigationLink(destination: SavedAddressScreen(), isActive: $navigateToSavedAddressScreen) {
                        EmptyView()
                    }
        }
        .onReceive(viewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(upiViewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{ $0}, perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.brandColor,
                onGoBackToHome: {
                    isCheckoutMainScreenFocused = true
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
            GeneralSuccessScreen(transactionID: transactionId, date: StringUtils.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: StringUtils.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "",currencySymbol: viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "", onDone: {
                sessionCompleteScreen = false
                isCheckoutMainScreenFocused = true
//                presentationMode.wrappedValue.dismiss()
            },brandColor: viewModel.brandColor)
        }
        .bottomSheet(isPresented: $showTimerSheet) {
            UpiTimerSheet(onCancelButton: {
                showCancelPopup = true
            },_vpa: $shopperVpa, brandColor: viewModel.brandColor)
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
                            brandColor: viewModel.brandColor
                        )
                    }
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            fetchStatusViewModel.startFetchingStatus(methodType: "UpiIntent")
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: paymentUrl,
                htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    fetchStatusViewModel.startFetchingStatus(methodType: "UpiCollect")
                }
            )
        }
        .onChange(of: viewModel.isAddressScreenRequiredToCompleteDetails) {focused in
            if(focused) {
                navigateToAddressScreen = true
            }
        }
    }
    
    private func handlePaymentAction(_ action: PaymentAction) {
        Task {
            status = await viewModel.checkoutManager.getStatus()
            transactionId = await viewModel.checkoutManager.getTransactionId()
            switch action {
            case .showFailed(let message):
                upiViewModel.isLoading = false
                await viewModel.checkoutManager.setStatus("FAILED")
                fetchStatusViewModel.stopFetchingStatus()
                errorReason = message
                sessionFailedScreen = true
            case .showSuccess(let time):
                await viewModel.checkoutManager.setStatus("SUCCESS")
                upiViewModel.isLoading = false
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
            case .openIntentUrl(let base64Url):
                upiViewModel.isLoading = true
                openURL(urlString: base64Url)
            case .openUpiTimer(let vpa) :
                fetchStatusViewModel.startFetchingStatus(methodType: "UpiCollect")
                shopperVpa = vpa
                showTimerSheet = true
            case .openQRUrl(url: let url):
                upiViewModel.qrUrl = url
            }
        }
    }
    
    private func openURL(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                isUserIntentProcessing = true
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
