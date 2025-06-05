//
//  BoxpayCheckout.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 15/05/25.
//

import SwiftUICore
import SwiftUI
import SDWebImageSVGCoder

public struct BoxpayCheckout : View {
    var token : String
    var shopperToken : String?
    var configurationOption : ConfigOptions?
    var onPaymentResult : (PaymentResultObject) -> Void
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
    
    @State private var selectedRecommendedInstrumentValue : String = ""
    @State private var selectedRecommendedDisplayValue : String = ""
    @State private var selectedSavedInstrumentValue : String = ""
    
    @State private var navigateToCardScreen = false
    @State private var navigateToWalletScreen = false
    @State private var navigateToNetBankingScreen = false
    @State private var navigateToBnplScreen = false
    @State private var navigateToEmiScreen = false
    @State private var navigateToAddressScreen = false
    
    @State private var isCheckoutMainScreenFocused = false
    @State private var isAddressUpdated = false
    
    @State private var paymentUrl : String? = nil
    @State private var paymentHtmlString: String? = nil
    @State private var showWebView = false
    
    @State private var status : String = ""
    @State private var transactionId : String = ""
    
    
    public init(
            token: String,
            shopperToken: String?,
            configurationOptions: ConfigOptions? = nil,
            onPaymentResult: @escaping (PaymentResultObject) -> Void
        ){
            CustomFontLoader.loadFonts()
            self.token = token
            self.shopperToken = shopperToken
            self.configurationOption = configurationOptions
            self.onPaymentResult = onPaymentResult
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
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
                            triggerPaymentStatusCallBack()
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    ScrollView {
                        if viewModel.isShippingEnabled || viewModel.isFullNameEnabled || viewModel.isMobileNumberEnabled || viewModel.isEmailIdEnabled {
                            TitleHeaderView(text: viewModel.isShippingEnabled ? "Address" : "Personal Details")
                            AddressSectionView(
                                address: $viewModel.address,
                                isShippingEnabled: $viewModel.isShippingEnabled,
                                isShippingEdiable: $viewModel.isShippingEditable,
                                isFullNameEnabled: $viewModel.isFullNameEnabled,
                                isFullNameEditable: $viewModel.isFullNameEditable,
                                isPhoneEnabled: $viewModel.isMobileNumberEnabled,
                                isPhoneEditable: $viewModel.isMobileNumberEditable,
                                isEmailEnabled: $viewModel.isEmailIdEnabled,
                                isEmailEditable: $viewModel.isEmailIdEditable,
                                fullNameText: $viewModel.fullNameText,
                                phoneNumberText: $viewModel.phoneNumberText,
                                emailIdText: $viewModel.emailIdText,
                                brandColor: viewModel.brandColor,
                                onClick:{
                                    navigateToAddressScreen = true
                                }
                            )
                            .id(viewModel.fullNameText + viewModel.phoneNumberText + viewModel.emailIdText + viewModel.address)
                        }
                        if (!viewModel.recommendedIds.isEmpty) {
                            TitleHeaderView(text: "Recommended")
                                .padding(.bottom, 8)
                            VStack(spacing:0) {
                                ForEach(Array(viewModel.recommendedIds.prefix(2).enumerated()), id: \.offset) { index, item in
                                    PaymentOptionView(
                                        isSelected: selectedRecommendedInstrumentValue == item.instrumentRef,
                                        imageUrl: item.logoUrl ?? "",
                                        title: item.displayValue ?? "",
                                        currencySymbol: viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "",
                                        amount: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "",
                                        instrumentValue: item.instrumentRef ?? "",
                                        brandColor: viewModel.brandColor,
                                        onClick: { string in
                                            selectedSavedInstrumentValue = ""
                                            selectedRecommendedInstrumentValue = string
                                            selectedRecommendedDisplayValue = item.displayValue ?? ""
                                        },
                                        onProceedButton: {
                                            upiViewModel.postRecommendedOrSavedInstrumentRef(selectedRecommendedInstrumentValue, methodType: "UpiCollect", selectedRecommendedDisplayValue)
                                        },
                                        fallbackImage: "upi_logo",
                                        showLastUsed : item.instrumentRef == viewModel.recommendedIds[0].instrumentRef
                                    )
                                    if index < min(1, viewModel.recommendedIds.prefix(2).count - 1) {
                                        Divider() // Optional: Adjust Divider's padding if needed
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        if(viewModel.upiIntentMethod || viewModel.upiCollectMethod) {
                            TitleHeaderView(text: "Pay by any UPI")
                                .padding(.bottom, 8)
                        }
                        
                        UpiScreen(
                            isUpiIntentVisible: $viewModel.upiIntentMethod,
                            isGpayVisible: isGooglePayInstalled(),
                            isPaytmVisible: isPaytmInstalled(),
                            isPhonePeVisible: isPhonePeInstalled(),
                            brandColor: viewModel.brandColor,
                            totalAmount: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "",
                            currencySymbol: viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "",
                            isUpiCollectVisible: $viewModel.upiCollectMethod,
                            handleUpiPayment: upiViewModel.initiateUpiPostRequest,
                            savedUpiIds: $viewModel.recommendedIds,
                            selectedSavedUpiId : $selectedSavedInstrumentValue,
                            onClickSavedUpi: {selectedUpiId, selectedUpiDisplayValue in
                                selectedRecommendedInstrumentValue = ""
                                selectedSavedInstrumentValue = selectedUpiId
                                selectedRecommendedDisplayValue = selectedUpiDisplayValue
                            },
                            onProceedSavedUpiId: { strign in
                                upiViewModel.postRecommendedOrSavedInstrumentRef(selectedSavedInstrumentValue, methodType: "UpiCollect", selectedRecommendedDisplayValue)
                            }
                        )

                        
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
            NavigationLink(destination: AddAddressScreen(isAddressUpdated: $isAddressUpdated,isCheckoutFocused: $isCheckoutMainScreenFocused), isActive: $navigateToAddressScreen) {
                        EmptyView()
                    }
        }
        .onAppear {
            if !viewModel.isInitialized {
                viewModel.initialize(token: token, shopperToken: shopperToken, config: configurationOption, callback: onPaymentResult)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(upiViewModel.$actions.compactMap { $0 }, perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{ $0}, perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.brandColor,
                onGoBackToHome: {
                    PaymentCallBackManager.shared.triggerPaymentResult(result: PaymentResultObject(status: status, transactionId: transactionId))
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
            GeneralSuccessScreen(transactionID: transactionId, date: StringUtils.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: StringUtils.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "",currencySymbol: viewModel.sessionData?.paymentDetails.money.currencySymbol ?? "", onDone: {
                sessionCompleteScreen = false
                PaymentCallBackManager.shared.triggerPaymentResult(result: PaymentResultObject(status: status, transactionId: transactionId))
                presentationMode.wrappedValue.dismiss()
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
        .onChange(of: isCheckoutMainScreenFocused) { focused in
            if focused {
                triggerPaymentStatusCallBack()
            }
        }
        .onChange(of: isAddressUpdated) { focused in
            if focused {
                Task {
                    viewModel.address = await viewModel.formattedAddress()
                    let firstName = await viewModel.userDataManager.getFirstName() ?? ""
                    let lastName = await viewModel.userDataManager.getLastName() ?? ""
                    viewModel.fullNameText = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                    viewModel.phoneNumberText = await viewModel.userDataManager.getPhone() ?? ""
                    viewModel.emailIdText = await viewModel.userDataManager.getEmail() ?? ""
                    
                    isAddressUpdated = false
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: URL(string: paymentUrl ?? ""), htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    upiViewModel.isLoading = true
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
    
    private func triggerPaymentStatusCallBack() {
        Task {
            let status = await viewModel.checkoutManager.getStatus()
            let transactionId = await viewModel.checkoutManager.getTransactionId()

            PaymentCallBackManager.shared.triggerPaymentResult(
                result: PaymentResultObject(status: status, transactionId: transactionId)
            )

            viewModel.checkoutManager.clearAllFields()
            viewModel.userDataManager.clearAllFields()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

private struct AddressSectionView: View {
    @Binding var address: String
    @Binding var isShippingEnabled: Bool
    @Binding var isShippingEdiable : Bool
    @Binding var isFullNameEnabled: Bool
    @Binding var isFullNameEditable: Bool
    @Binding var isPhoneEnabled: Bool
    @Binding var isPhoneEditable: Bool
    @Binding var isEmailEnabled: Bool
    @Binding var isEmailEditable: Bool
    @Binding var fullNameText: String
    @Binding var phoneNumberText: String
    @Binding var emailIdText: String
    var brandColor: String

    var onClick: () -> Void

    var body: some View {
        if isEditableSectionAvailable {
            Button(action: onClick) {
                contentView
            }
        } else {
            contentView // show content without button interaction
        }
    }


    @ViewBuilder
    private var contentView: some View {
        if isShippingEnabled && address.isEmpty {
            addPromptView(text: "Add new address")
        } else if needsPersonalDetails {
            addPromptView(text: "Add personal details")
        } else {
            infoDisplayView
        }
    }
    
    private var isEditableSectionAvailable: Bool {
        (isShippingEnabled && isShippingEdiable) ||
        (isFullNameEnabled && isFullNameEditable) ||
        (isPhoneEnabled && isPhoneEditable) ||
        (isEmailEnabled && isEmailEditable)
    }

    private var needsPersonalDetails: Bool {
        (isEmailEnabled && emailIdText.isEmpty) ||
        (isPhoneEnabled && phoneNumberText.isEmpty) ||
        (isFullNameEnabled && fullNameText.isEmpty)
    }

    private func addPromptView(text: String) -> some View {
        HStack {
            Image(frameworkAsset: "add_green", isTemplate: true)
                .foregroundColor(Color(hex: brandColor))
                .frame(width:16, height:16)
            Text(text)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: brandColor))
            Spacer()
            Image(frameworkAsset: "chevron")
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(90))
        }
        .commonCardStyle()
    }

    private var infoDisplayView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(frameworkAsset: isShippingEnabled ? "map_pin_gray" : "ic_person")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
                    .scaledToFit()

                VStack(alignment: .leading, spacing: 0) {
                    infoHeaderView
                    infoSubTextView
                }

                Spacer()

                Image(frameworkAsset: "chevron")
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(90))
            }
            .commonCardStyle()
        }
    }

    @ViewBuilder
    private var infoHeaderView: some View {
        HStack {
            if isShippingEnabled {
                Text("Deliver at ")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
                Text("Others")
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(Color(hex: "#4F4D55"))
            } else {
                if isFullNameEnabled {
                    Text(fullNameText)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if isFullNameEnabled && isPhoneEnabled {
                    Text("|")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
                if isPhoneEnabled {
                    Text(phoneNumberText)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                }
            }
        }
    }

    @ViewBuilder
    private var infoSubTextView: some View {
        if isShippingEnabled {
            Text(address)
                .font(.custom("Poppins-SemiBold", size: 14))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if isEmailEnabled {
            Text(emailIdText)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(Color(hex: "#4F4D55"))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - View Extension for Common Card Style
private extension View {
    func commonCardStyle() -> some View {
        self
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal, 16)
    }
}

