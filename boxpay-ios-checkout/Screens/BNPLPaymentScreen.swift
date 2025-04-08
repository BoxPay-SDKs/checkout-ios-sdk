//
//  BNPLPaymentScreen.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 06/02/25.
//


import SwiftUI
import AlertToast
import Foundation

@available(iOS 15.0, *)
struct BNPLPaymentScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @State private var bnplList: [BnplDataClass] = []
    @State private var filteredBnpl: [BnplDataClass] = []
    @State private var searchText: String = ""
    @State private var selectedBnpl: BnplDataClass?  // Track the selected BNPL option
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
                    title: "Choose BNPL Option",
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
                                Text("All BNPL Options")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            bnplListView
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
                    isLoading = false
                    mapBNPL(from: checkOutViewModel.paymentOptionList)
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
            TextField("Search for BNPL option", text: $searchText)
                .padding(10)
                .onChange(of: searchText) { _ in
                    filterBnpl()
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
    
    private var bnplListView: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(filteredBnpl, id: \.bnplName) { bnpl in
                VStack(alignment: .leading, spacing: 1) {
                    bnplRow(bnpl: bnpl)
                    
                    if selectedBnpl == bnpl {
                        proceedToPayButton(bnpl: bnpl)
                            .padding(.top, 1)
                            .padding(.bottom, 5)
                    }
                    
                    if bnpl != filteredBnpl.last {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
                .background(selectedBnpl == bnpl ? Color.green.opacity(0.1) : Color.clear)  // Apply background to whole item
            }
            if (filteredBnpl.isEmpty  && !searchText.isEmpty) {
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

    private func bnplRow(bnpl: BnplDataClass) -> some View {
        Button(action: {
            selectedBnpl = bnpl
        }) {
            HStack {
                bnplImageView(bnpl: bnpl)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.leading, 15)
                
                Text(bnpl.bnplName)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: selectedBnpl == bnpl ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selectedBnpl == bnpl ? .green : .gray)
                    .font(.system(size: 22))
                    .padding(.trailing, 15)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle()) // ✅ Makes the entire row tappable
            .frame(minHeight: 55)
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button animation
    }



    private func bnplImageView(bnpl: BnplDataClass) -> some View {
        Group {
            if let imageURL = URL(string: bnpl.bnplImage) {
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

    private func proceedToPayButton(bnpl: BnplDataClass) -> some View {
        Button(action: {
            print("Proceed to pay \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0") for \(bnpl.bnplName)")
            repeatingTask.startRepeatingTask(
                showSuccesScreen: $showSuccessSheet,
                showFailureScreen: $showFailureScreen,
                isLoading: $isLoading
            )
            commonInitializePaymentViewModel.postRequest(InstrumentTypeValue: bnpl.bnplInstrumentTypeValue, isLoading: $isLoading, showFailureScreen: $showFailureScreen,screenName: "BNPLScreen")
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


    
    private func mapBNPL(from paymentMethods: [PaymentMethod]) {
        var bnplOptions: [BnplDataClass] = []
        
        for paymentMethod in paymentMethods {
            if paymentMethod.type == "BuyNowPayLater" {
                var bnplImage = paymentMethod.logoUrl ?? ""
                if bnplImage.starts(with: "/assets") {
                    bnplImage = "https://checkout.boxpay.in" + bnplImage
                }
                
                let bnpl = BnplDataClass(
                    bnplName: paymentMethod.title ?? "",
                    bnplImage: bnplImage,
                    bnplBrand: paymentMethod.brand ?? "",
                    bnplInstrumentTypeValue: paymentMethod.instrumentTypeValue ?? ""
                )
                
                bnplOptions.append(bnpl)
            }
        }
        
        self.bnplList = bnplOptions
        self.filteredBnpl = bnplOptions  // Initially show all BNPL options
    }
    
    private func filterBnpl() {
        if searchText.isEmpty {
            filteredBnpl = bnplList
        } else {
            filteredBnpl = bnplList.filter { bnpl in
                bnpl.bnplName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    

    struct BnplDataClass: Identifiable, Equatable {
        var id = UUID()
        var bnplName: String
        var bnplImage: String
        var bnplBrand: String
        var bnplInstrumentTypeValue: String
    }

}

struct BNPLPaymentScreen_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            BNPLPaymentScreen()
        }
    }
}
