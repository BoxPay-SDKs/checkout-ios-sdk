//
//  NetBankingScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 06/02/25.
//


import SwiftUI
import AlertToast
import Foundation


@available(iOS 15.0, *)
struct NetBankingScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @State private var bankList: [NetbankingDataClass] = []
    @State private var filteredBanks: [NetbankingDataClass] = []
    @State private var searchText: String = ""
    @State private var selectedBank: NetbankingDataClass?  // Track the selected bank
    @State private var isLoading: Bool = true
    @State private var showFailureScreen: Bool = false
    @State private var showSuccessSheet: Bool = false
    
    @State private var showWebView = false
    @State private var dynamicURL: String = ""
    @ObservedObject var commonInitializePaymentViewModel = CommonInitializePaymentViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    private let repeatingTask = RepeatingTask()
    
    private var currencySymbol: String{
        checkOutViewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
        }
    
    var body: some View {
        NavigationView {
            VStack {
                PaymentHeaderView(
                    title: "Choose Bank",
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
                                Text("All Banks")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            bankListView
                            
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
                print("WebView closed by user!") // ✅ Detect if user closed manually
                showFailureScreen = true // ✅ Custom function to handle dismissal
                isLoading = false
            }) {
                if let validURL = URL(string: dynamicURL) {
                    WebView(
                        url: validURL,
                        onDismiss: {
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
                //onTap would call either if `tapToDismiss` is true/false
                //If tapToDismiss is true, onTap would call and then dismiss the alert
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
                    mapBanks(from: checkOutViewModel.paymentOptionList)
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
            TextField("Search for bank", text: $searchText)
                .padding(10)
                .onChange(of: searchText) { _ in
                    filterBanks()
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
    
    private var bankListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filteredBanks, id: \.bankName) { bank in
                VStack(alignment: .leading, spacing: 1) {
                    bankRow(bank: bank)
                    
                    if selectedBank == bank {
                        proceedToPayButton(bank: bank)
                            .padding(.top, 1)
                            .padding(.bottom, 5)
                    }
                    
                    if bank != filteredBanks.last {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
                .background(selectedBank == bank ? Color.green.opacity(0.1) : Color.clear)  // Apply background to whole item
            }
            
            if (filteredBanks.isEmpty  && !searchText.isEmpty) {
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

    private func bankRow(bank: NetbankingDataClass) -> some View {
        Button(action: {
            selectedBank = bank
        }) {
            HStack {
                bankImageView(bank: bank)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.leading, 15)
                
                Text(bank.bankName)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: selectedBank == bank ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selectedBank == bank ? .green : .gray)
                    .font(.system(size: 22))
                    .padding(.trailing, 15)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle()) // ✅ Makes the entire row tappable
            .frame(minHeight: 55)
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button animation
    }



    private func bankImageView(bank: NetbankingDataClass) -> some View {
        Group {
            if let imageURL = URL(string: bank.bankImage) {
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

    private func proceedToPayButton(bank: NetbankingDataClass) -> some View {
        Button(action: {
            print("Proceed to pay  \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0") for \(bank.bankName)")
            
            repeatingTask.startRepeatingTask(
                showSuccesScreen: $showSuccessSheet,
                showFailureScreen: $showFailureScreen,
                isLoading: $isLoading
            )
            commonInitializePaymentViewModel.postRequest(InstrumentTypeValue: bank.bankInstrumentTypeValue, isLoading: $isLoading, showFailureScreen: $showFailureScreen,screenName: "NetBankingScreen")
        }) {
            Text("Proceed to Pay \(currencySymbol) \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(8)
        }
        .padding(.trailing, 15)
        .padding(.leading, 15)
    }


    
    private func mapBanks(from paymentMethods: [PaymentMethod]) {
        var banks: [NetbankingDataClass] = []

        for paymentMethod in paymentMethods {
            if paymentMethod.type == "NetBanking" {
                var bankImage = paymentMethod.logoUrl ?? ""
                if bankImage.starts(with: "/assets") {
                    bankImage = "https://checkout.boxpay.in" + bankImage
                }

                let bank = NetbankingDataClass(
                    bankName: paymentMethod.title ?? "",
                    bankImage: bankImage,
                    bankBrand: paymentMethod.brand ?? "",
                    bankInstrumentTypeValue: paymentMethod.instrumentTypeValue ?? ""
                )

                banks.append(bank)
            }
        }

        // ✅ Sort banks alphabetically
        self.bankList = banks.sorted { $0.bankName.localizedCaseInsensitiveCompare($1.bankName) == .orderedAscending }
        self.filteredBanks = self.bankList  // ✅ Initially show sorted banks
    }

    
    private func filterBanks() {
        if searchText.isEmpty {
            filteredBanks = bankList
        } else {
            filteredBanks = bankList.filter { bank in
                bank.bankName.lowercased().contains(searchText.lowercased())
            }
        }
        
        // ✅ Ensure `filteredBanks` remains sorted after filtering
        filteredBanks.sort { $0.bankName.localizedCaseInsensitiveCompare($1.bankName) == .orderedAscending }
    }

    

    struct NetbankingDataClass: Identifiable, Equatable {
        var id = UUID()
        var bankName: String
        var bankImage: String
        var bankBrand: String
        var bankInstrumentTypeValue: String
    }

}

struct NetBankingScreen_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            NetBankingScreen()
        } else {
            // Fallback on earlier versions
        }
    }
}
