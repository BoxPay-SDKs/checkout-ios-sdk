//
//  NetBankingScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUICore
import SwiftUI

struct NetBankingScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isCheckoutFocused : Bool

    @StateObject private var viewModel = NetBankingViewModel()
    @State private var searchTextField: String = ""
    @State private var isSearchTextFieldFocused: Bool = false
    @State private var selectedInstrumentValue: String = ""
    @State private var selectedPopularInstrumentVakue : String = ""
    
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
        VStack {
            if viewModel.isFirstLoad {
                ShimmerPlaceholderScreen()
            } else if viewModel.isLoading {
                BoxpayLoaderView()
            } else {
                VStack(alignment: .leading) {
                    VStack {
                        HeaderView(
                            text: "Select Bank",
                            showDesc: true,
                            showSecure: true,
                            itemCount: viewModel.itemsCount,
                            currencySymbol: viewModel.currencySymbol,
                            amount: viewModel.totalAmount,
                            onBackPress: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        FloatingLabelTextField(placeholder: "Search for bank", text: $searchTextField, isValid: .constant(true), onChange : { newText in
                            searchTextField = newText
                            filterBanks(matching: newText)
                        },isFocused: $isSearchTextFieldFocused, trailingIcon: .constant(""), leadingIcon: .constant("ic_search"), isSecureText: .constant(false))
                            .frame(height: 40)
                            .padding(16)
                    }
                    .background(Color.white)
                    
                    ScrollView {
                        if(searchTextField.isEmpty && !viewModel.popularBankDataClass.isEmpty) {
                            HStack {
                                Text("Popular Banks")
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                    .foregroundColor(Color(hex: "#020815").opacity(0.71))
                                Spacer()
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 16)
                            VStack(spacing : 0) {
                                ForEach(Array(viewModel.popularBankDataClass.enumerated()), id: \.element.id) { index, item in
                                    PaymentOptionView(
                                        isSelected: selectedPopularInstrumentVakue == item.instrumentTypeValue,
                                        imageUrl: item.image,
                                        title: item.title,
                                        currencySymbol: viewModel.currencySymbol,
                                        amount: viewModel.totalAmount,
                                        instrumentValue: item.instrumentTypeValue,
                                        brandColor: viewModel.brandColor,
                                        onClick: { string in
                                            selectedPopularInstrumentVakue = string
                                            selectedInstrumentValue = ""
                                        },
                                        onProceedButton: {
                                            viewModel.initiateNetBankingPostRequest(instrumentValue: selectedPopularInstrumentVakue.isEmpty ? selectedInstrumentValue : selectedPopularInstrumentVakue)
                                        },
                                        fallbackImage: "ic_netbanking_semi_bold"
                                    )
                                    if index < viewModel.popularBankDataClass.count - 1 {
                                            Divider()// Remove extra padding around Divider
                                        }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal, 16)
                        }
                        HStack {
                            Text("All Banks")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(Color(hex: "#020815").opacity(0.71))
                            Spacer()
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            if(viewModel.netBankingDataClass.isEmpty) {
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
                                ForEach(Array(viewModel.netBankingDataClass.enumerated()), id: \.element.id) { index, item in
                                    PaymentOptionView(
                                        isSelected: selectedInstrumentValue == item.instrumentTypeValue,
                                        imageUrl: item.image,
                                        title: item.title,
                                        currencySymbol: viewModel.currencySymbol,
                                        amount: viewModel.totalAmount,
                                        instrumentValue: item.instrumentTypeValue,
                                        brandColor: viewModel.brandColor,
                                        onClick: { string in
                                            selectedInstrumentValue = string
                                            selectedPopularInstrumentVakue = ""
                                        },
                                        onProceedButton: {
                                            viewModel.initiateNetBankingPostRequest(instrumentValue: selectedPopularInstrumentVakue.isEmpty ? selectedInstrumentValue : selectedPopularInstrumentVakue)
                                        },
                                        fallbackImage: "ic_netbanking_semi_bold"
                                    )
                                    if index < viewModel.netBankingDataClass.count - 1 {
                                            Divider()// Remove extra padding around Divider
                                        }
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                    }
                }
                .background(Color(hex: "#F5F6FB"))
            }
        }
        .onAppear {
            viewModel.getNetBankingPaymentMethods()
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
            }
        }
    }
    
    func filterBanks(matching text: String) {
        selectedInstrumentValue = ""
        if(text.isEmpty) {
            viewModel.netBankingDataClass = viewModel.defaultNetBankingDataClass
            return
        }
        let list = viewModel.defaultNetBankingDataClass
        let lowercasedText = text.lowercased()

        viewModel.netBankingDataClass = list.filter { item in
            let words = item.title.lowercased().split(separator: " ") // Split into words
                return words.contains { word in
                    word.hasPrefix(lowercasedText)
                }
            }
        }
}
