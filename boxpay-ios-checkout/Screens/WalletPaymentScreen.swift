//
//  WalletPaymentScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 04/02/25.
//

import SwiftUI
import AlertToast

@available(iOS 15.0, *)
struct WalletPaymentScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @State private var walletList: [WalletDataClass] = []
    @State private var filteredWallets: [WalletDataClass] = []
    @State private var searchText: String = ""
    @State private var selectedWallet: WalletDataClass?  // Track the selected wallet
    @State private var isLoading: Bool = true
    @State private var showFailureScreen: Bool = false
    @State private var showSuccessSheet: Bool = false
    
    @State private var showWebView = false
    @State private var dynamicURL: String = ""
    @ObservedObject var commonInitializePaymentViewModel = CommonInitializePaymentViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    private let repeatingTask = RepeatingTask()
    @State private var isWebViewClosedProgrammatically = false
    private var currencySymbol: String{
        checkOutViewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
        }
    
    var body: some View {
        NavigationView {
            VStack {
                PaymentHeaderView(
                    title: "Choose Wallet",
                    itemCount: checkOutViewModel.sessionData?.paymentDetails.order?.items?.count ?? 0,
                    totalPrice: checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                    currencySymbol: currencySymbol,
                    onBack: { presentationMode.wrappedValue.dismiss() }
                )
                Spacer()
                Divider()
                
                // Search TextField with rounded rectangle gray background
                searchField
                
                // ScrollView with grey background
                ZStack {
                    Color(.systemGray6) // Grey background
                        .ignoresSafeArea()
                    
                    ScrollView {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("All Wallets")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            walletListView
                            
                            FooterView()
                                .padding(.top, 10)
                        }
                    }
                    .hideKeyboardOnTap()
                }
            }
            .onChange(of: commonInitializePaymentViewModel.redirectURL) { newURL in
                // Update state variables when redirectURL changes
                if let url = newURL, !url.isEmpty {
                    dynamicURL = url
                    showWebView = true  // Show WebView when URL is set
                }
            }
            .sheet(isPresented: $showWebView, onDismiss: {
                if !isWebViewClosedProgrammatically {
                    print("WebView closed by user!") // ✅ Detect if user closed manually
                    showFailureScreen = true
                    isLoading = false
                }
                isWebViewClosedProgrammatically = false // ✅ Reset the flag
            }) {
                if let validURL = URL(string: dynamicURL) {
                    WebView(
                        url: validURL,
                        onDismiss: {
                            isWebViewClosedProgrammatically = true
                            showWebView = false
                            print("WebView closed after action!") // ✅ Detect if closed after an action
                        }
                    )
                }
            }
            .sheet(isPresented: $showFailureScreen) {
                if #available(iOS 16.0, *) {
                    PaymentFailureScreen(transactionID: paymentViewModel.transactionId, reasonCode: paymentViewModel.reasonCode, reason: paymentViewModel.statusReason,
                        onRetryPayment: {
                            print("Retry Payment action from sheet")
                            showFailureScreen = false
                            repeatingTask.stopRepeatingTask()
                            //dismiss()
                        },
                        onReturnToPaymentOptions: {
                            showFailureScreen = false
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
            .sheet(isPresented: $showSuccessSheet) {
                if #available(iOS 16.0, *) {
                    GeneralSuccessScreen(
                        transactionID: paymentViewModel.transactionId,
                        date: paymentViewModel.transactionDate, // Directly access the value
                        time: paymentViewModel.transactionTime, // Directly access the value
                        paymentMethod: paymentViewModel.paymentMethod, // Directly access the value
                        totalAmount: paymentViewModel.totalAmount // Directly access the value
                    ) {
                        // Define result before triggering the callback
                        let result = PaymentResultObject(status: paymentViewModel.status,transactionId: paymentViewModel.transactionId,operationId: "")
                        
                        // Trigger the callback to pass the result back
                        PaymentCallbackManager.shared.triggerPaymentResult(result: result)
                        
                        //closes the MainCheckoutSheet
                        //DismissManager.shared.dismissAll() to dismiss all registered screens at once
                        DismissManager.shared.dismiss("MainCheckoutSheet")
                        // Close the success screen
                        repeatingTask.stopRepeatingTask()
                        showSuccessSheet = false
                        dismiss()
                    }
                    .presentationDetents([.height(500)]) // Optional: Set height dynamically
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
                } else {
                    // Fallback on earlier versions
                }
            }
            .toast(isPresenting: $isLoading, duration: 100, tapToDismiss: false, alert: {
                AlertToast(type: .loading)
                //AlertToast goes here
            }, onTap: {
                //onTap would call either if `tapToDismis` is true/false
                //If tapToDismiss is true, onTap would call and then dismis the alert
            }, completion: {
                isLoading = false
                //Completion block after dismiss
            })
            .background(Color.white)
            .onAppear {
                let apiManager = APIManager()
                checkOutViewModel.getCheckoutSession(token: apiManager.getMainToken())
                repeatingTask.paymentViewModel = paymentViewModel
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    mapWallets(from: checkOutViewModel.paymentOptionList)
                    isLoading = false
                }
            }
            .onDisappear {
                repeatingTask.stopRepeatingTask()
            }
            .background(Color.white.ignoresSafeArea())
            .preferredColorScheme(.light)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray).padding(.leading,10)
            TextField("Search for wallet", text: $searchText)
                .padding(10)
                .onChange(of: searchText) { _ in
                    filterWallets()
                }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    private var walletListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filteredWallets, id: \.walletName) { wallet in
                VStack(alignment: .leading, spacing: 1) {
                    walletRow(wallet: wallet)
                    
                    if selectedWallet == wallet {
                        proceedToPayButton(wallet: wallet)
                            .padding(.top, 1)
                            .padding(.bottom, 5)
                    }
                    
                    if wallet != filteredWallets.last {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
                .background(selectedWallet == wallet ? Color.green.opacity(0.1) : Color.clear)  // Apply background to whole item
            }
            
            if (filteredWallets.isEmpty  && !searchText.isEmpty) {
                VStack(alignment: .center, spacing: 10) {
                    Image(frameworkAsset: "search_no_result_found")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                    
                    Text("Oops...No results found")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Please try another search")
                        .font(.system(size: 18, weight: .regular))
                }
                .frame(maxWidth: .infinity) // 👈 Ensures full width
                .padding(.vertical, 70)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }

    private func walletRow(wallet: WalletDataClass) -> some View {
        Button(action: {
            selectedWallet = wallet
        }) {
            HStack {
                walletImageView(wallet: wallet)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.leading, 15)
                
                Text(wallet.walletName)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: selectedWallet == wallet ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selectedWallet == wallet ? .green : .gray)
                    .font(.system(size: 22))
                    .padding(.trailing, 15)
            }
            .padding(.vertical, 10) // ✅ Ensures a good tap area
            .contentShape(Rectangle()) // ✅ Makes the entire row tappable
            .frame(minHeight: 55)
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button animation
    }



    private func walletImageView(wallet: WalletDataClass) -> some View {
        Group {
            if let imageURL = URL(string: wallet.walletImage) {
                SVGImageView(url: imageURL.absoluteString)
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .foregroundColor(.red)
            }
        }
    }

    private func proceedToPayButton(wallet: WalletDataClass) -> some View {
        Button(action: {
            print("Proceed to pay \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0") for \(wallet.walletName)")
            
            repeatingTask.startRepeatingTask(
                showSuccesScreen: $showSuccessSheet,
                showFailureScreen: $showFailureScreen,
                isLoading: $isLoading
            )
            commonInitializePaymentViewModel.postRequest(InstrumentTypeValue: wallet.walletInstrumentTypeValue, isLoading: $isLoading, showFailureScreen: $showFailureScreen,screenName: "WalletScreen")
            
        }) {
            Text("Proceed to Pay \(currencySymbol) \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(8)
        }.padding(.trailing,15)
        .padding(.leading,15)
    }

    
    private func mapWallets(from paymentMethods: [PaymentMethod]) {
        var wallets: [WalletDataClass] = []

        for paymentMethod in paymentMethods {
            if paymentMethod.type == "Wallet" {
                var walletImage = paymentMethod.logoUrl ?? ""
                if walletImage.starts(with: "/assets") {
                    walletImage = "https://checkout.boxpay.in" + walletImage
                }

                let wallet = WalletDataClass(
                    walletName: paymentMethod.title ?? "",
                    walletImage: walletImage,
                    walletBrand: paymentMethod.brand ?? "",
                    walletInstrumentTypeValue: paymentMethod.instrumentTypeValue ?? ""
                )

                wallets.append(wallet)
            }
        }

        // ✅ Sort wallets alphabetically
        self.walletList = wallets.sorted {
            $0.walletName.localizedCaseInsensitiveCompare($1.walletName) == .orderedAscending
        }

        self.filteredWallets = self.walletList  // ✅ Initially show sorted wallets
    }

    
    private func filterWallets() {
        if searchText.isEmpty {
            filteredWallets = walletList
        } else {
            filteredWallets = walletList.filter { wallet in
                wallet.walletName.lowercased().contains(searchText.lowercased())
            }
        }

        // ✅ Ensure filtered wallets are also sorted
        filteredWallets.sort {
            $0.walletName.localizedCaseInsensitiveCompare($1.walletName) == .orderedAscending
        }
    }

}

struct WalletListView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            WalletPaymentScreen()
        }
    }
}

