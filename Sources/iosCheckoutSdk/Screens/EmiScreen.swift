//
//  EmiScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore
import SwiftUI

struct EmiScreen : View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isCheckoutFocused : Bool

    @StateObject private var viewModel = EmiViewModel()
    @StateObject private var fetchStatusViewModel = FetchStatusViewModel()
    
    @State private var sessionExpireScreen = false
    @State private var sessionCompleteScreen = false
    @State private var sessionFailedScreen = false
    @State private var errorReason = ""
    @State private var timeStamp = ""
    @State private var paymentUrl : String? = nil
    @State private var paymentHtmlString: String? = nil
    @State private var showWebView = false
    
    @State private var searchTextField : String = ""
    @State private var isSearchTextFieldFocused : Bool = false
    
    @State private var isSelectTenureScreenVisible = false
    @State private var isCardScreenVisible = false
    
    @State private var selectedBank : Bank?
    @State private var selectedEMI :EmiList?
    
    @State private var selectedOtherInstrumentValue :String = ""
    
    var body: some View {
        VStack {
            if viewModel.isFirstLoad {
                ShimmerPlaceholderScreen()
            } else if viewModel.isLoading {
                BoxpayLoaderView()
            } else if isSelectTenureScreenVisible {
                SelectTenureScreen(selectedBank: selectedBank!, itemsCount: viewModel.itemsCount, currencySymbol: viewModel.currencySymbol, totalAmount: viewModel.totalAmount, brandColor: viewModel.brandColor,selectedCardType: viewModel.selectedCardType,fallBackImage: "ic_netbanking_semi_bold", isSelectScreenVisible: $isSelectTenureScreenVisible, onClickProceed : {emi in
                    selectedEMI = emi
                    isCardScreenVisible = true
                    isSelectTenureScreenVisible = false
                })
            } else if isCardScreenVisible {
                CardScreen(
                    isCheckoutFocused: $isCheckoutFocused,
                    durationNumber: selectedEMI?.duration,
                    bankName: selectedBank?.name,
                    bankUrl: selectedBank?.iconUrl,
                    offerCode: selectedEMI?.code,
                    emiAmount: selectedEMI?.amount,
                    interest: selectedEMI?.percent,
                    cardType: viewModel.selectedCardType,
                    emiIssuerBrand: selectedBank?.issuerBrand,
                    onClickBack: {
                        isCardScreenVisible = false
                        isSelectTenureScreenVisible = true
                    }
                )

            } else {
                VStack(alignment: .leading) {
                    VStack {
                        HeaderView(
                            text: "Choose EMI Option",
                            showDesc: true,
                            showSecure: false,
                            itemCount: viewModel.itemsCount,
                            currencySymbol: viewModel.currencySymbol,
                            amount: viewModel.totalAmount,
                            onBackPress: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.emiDataClass.cards.count, id: \.self) { index in
                                VStack(spacing: 4) {
                                    Text(viewModel.emiDataClass.cards[index].cardType)
                                        .font(.custom("Poppins-SemiBold", size: 14))
                                        .foregroundColor(viewModel.selectedCardType == viewModel.emiDataClass.cards[index].cardType ? Color(hex: viewModel.brandColor) : Color(hex: "#010102").opacity(0.45))
                                        .onTapGesture {
                                            viewModel.selectedCardType = viewModel.emiDataClass.cards[index].cardType
                                            searchTextField = ""
                                        }

                                    if viewModel.selectedCardType == viewModel.emiDataClass.cards[index].cardType {
                                        Divider()
                                            .frame(height: 2)
                                            .background(Color(hex: viewModel.brandColor))
                                    } else {
                                        Spacer().frame(height: 2)
                                    }
                                }
                                .frame(maxWidth: .infinity)

                            }
                        }
                        .frame(maxWidth: .infinity) // Ensure that the HStack takes up the full width
                        .background(Color.white)
                        .padding(.top, 4)
                        Divider()
                        FloatingLabelTextField(placeholder: "Search for bank", text: $searchTextField, isValid: .constant(true), onChange : { newText in
                            searchTextField = newText
                            filterBanks(matching: newText)
                        },isFocused: $isSearchTextFieldFocused, trailingIcon: .constant(""), leadingIcon: .constant("ic_search"), isSecureText: .constant(false))
                            .frame(height: 40)
                            .padding(16)
                    }
                    .background(Color.white)
                    if(viewModel.selectedCardType == "Others") {
                        Text("Others")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color(hex: "#020815").opacity(0.71))
                            .padding(.top, 12)
                            .padding(.horizontal, 16)
                    } else {
                        Text("All Banks")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color(hex: "#020815").opacity(0.71))
                            .padding(.top, 12)
                            .padding(.horizontal, 16)
                    }
                    
                    ScrollView {
                        VStack(spacing: 0) {
                                if let selectedCard = viewModel.emiDataClass.cards.first(where: { $0.cardType == viewModel.selectedCardType }) {
                                    let banks = selectedCard.banks
                                    if(banks.isEmpty) {
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
                                        ForEach(Array(banks.enumerated()), id: \.1.name) { index, bank in
                                            VStack(spacing: 0) {
                                                if(viewModel.selectedCardType == "Others") {
                                                    PaymentOptionView(isSelected: selectedOtherInstrumentValue == bank.cardLessEmiValue, imageUrl: bank.iconUrl, title: bank.name, currencySymbol: viewModel.currencySymbol, amount: viewModel.totalAmount, instrumentValue: bank.cardLessEmiValue, brandColor: viewModel.brandColor, onClick: { string in
                                                        selectedOtherInstrumentValue = string
                                                    }, onProceedButton: {
                                                        viewModel.initiatedOtherEmiPostRequest(instrumentValue: selectedOtherInstrumentValue)
                                                    }, fallbackImage: "ic_bnpl_semi_bold")
                                                } else {
                                                    EmiChooseBankView(
                                                        bankUrl: bank.iconUrl,
                                                        bankName: bank.name,
                                                        isNoCostApplied: bank.isNoCostApplied,
                                                        isLowCostApplied: bank.isLowCostApplied,
                                                        onClick: {
                                                            // Sort EMI list before assigning the bank
                                                            var sortedBank = bank
                                                            sortedBank.emiList.sort {
                                                                if $0.noCostApplied != $1.noCostApplied {
                                                                    return $0.noCostApplied // true comes before false
                                                                }
                                                                if $0.lowCostApplied != $1.lowCostApplied {
                                                                    return $0.lowCostApplied // true comes before false
                                                                }
                                                                return $0.duration < $1.duration
                                                            }

                                                            selectedBank = sortedBank
                                                            isSelectTenureScreenVisible = true
                                                        },
                                                        fallbackImage: "ic_netbanking_semi_bold"
                                                    )
                                                }
                                                if index < banks.count - 1 {
                                                    Divider()
                                                }
                                            }
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
            viewModel.getEmiPaymentMethod()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: viewModel.brandColor,
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
            },brandColor: viewModel.brandColor)
        }
        .bottomSheet(isPresented: $sessionCompleteScreen) {
            GeneralSuccessScreen(transactionID: viewModel.transactionId, date: GlobalUtils.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: GlobalUtils.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: viewModel.totalAmount,currencySymbol: viewModel.currencySymbol, onDone: {
                sessionCompleteScreen = false
                isCheckoutFocused = true
                presentationMode.wrappedValue.dismiss()
            },brandColor: viewModel.brandColor)
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: URL(string: paymentUrl ?? ""), htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    viewModel.isLoading = true
                    fetchStatusViewModel.startFetchingStatus(methodType: "NetBanking")
                }
            )
        }
    }
    
    func filterBanks(matching text: String) {
        // If text is empty, reset to default
        if text.isEmpty {
            viewModel.emiDataClass = viewModel.duplicateEmiDataClass
            return
        }

        let lowercasedText = text.lowercased()

            // Build new card list by filtering only the selected card type
            let filteredCards = viewModel.duplicateEmiDataClass.cards.map { card -> CardType in
                if card.cardType == viewModel.selectedCardType {
                    let filteredBanks = card.banks.filter { bank in
                        let words = bank.name.lowercased().split(separator: " ")
                        return words.contains { word in
                            word.hasPrefix(lowercasedText)
                        }
                    }
                    return CardType(cardType: card.cardType, banks: filteredBanks)
                } else {
                    return card // Leave unselected card types unchanged
                }
            }

            viewModel.emiDataClass = EmiDataClass(cards: filteredCards)
    }

    private func handlePaymentAction(_ action: PaymentAction) {
        Task {
            switch action {
            case .showFailed(let message):
                print("❌ Failed: - \(message)")
                viewModel.isLoading = false
                await viewModel.checkoutManager.setStatus("FAILED")
                fetchStatusViewModel.stopFetchingStatus()
                errorReason = message
                sessionFailedScreen = true
            case .showSuccess(let time):
                print("✅ Success: - \(time)")
                await viewModel.checkoutManager.setStatus("SUCCESS")
                viewModel.isLoading = false
                fetchStatusViewModel.stopFetchingStatus()
                timeStamp = time
                sessionCompleteScreen = true
            case .showExpired:
                print("⌛ Expired:")
                await viewModel.checkoutManager.setStatus("EXPIRED")
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
}


struct EmiChooseBankView : View {
    var bankUrl: String
    var bankName: String
    var isNoCostApplied : Bool
    var isLowCostApplied : Bool
    var onClick : () -> Void
    var fallbackImage : String
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                SVGImageView(url: bankUrl, fallbackImage: fallbackImage)
                VStack(alignment: .leading, spacing: 0) {
                    Text(bankName)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(Color(hex: "#4F4D55"))
                    HStack {
                        if(isNoCostApplied) {
                            FilterTag(filterText: "NO COST EMI")
                        }
                        if(isLowCostApplied) {
                            FilterTag(filterText: "LOW COST EMI")
                        }
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Image(frameworkAsset: "chevron")
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(90))
            }
            .onTapGesture {
                onClick()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}
