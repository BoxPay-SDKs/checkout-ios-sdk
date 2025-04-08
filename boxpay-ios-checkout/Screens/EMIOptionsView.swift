//
//  EMIOptionsView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 11/02/25.
//


import SwiftUI
import AlertToast

@available(iOS 15.0, *)
struct EMIOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @State private var selectedTab = 0
    let tabs = ["Credit Card", "Debit Card", "Others"]
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    @State private var creditCardEmiOptions: [PaymentMethod] = []
    @State private var creditCardEmiOptionsWithTags: [PaymentMethod] = []
    @State private var debitCardEmiOptions: [PaymentMethod] = []
    @State private var debitCardEmiOptionsWithTags: [PaymentMethod] = []
    @State private var othersEmiOptions: [PaymentMethod] = []
    @State private var othersEmiOptionsWithTags: [PaymentMethod] = []
    @State private var selectedEMIOptions: [PaymentMethod] = []
    @State private var allEmiPaymentOptions: [PaymentMethod] = []
    @State private var isFilteringNoCostEMI = false
    @State private var navigateToDetails = false
    @State private var isOthersTabSelected = false
    @State private var selectedBank: PaymentMethod? = nil // Track the selected bank
    
    @State private var showWebView = false
    @State private var dynamicURL: String = ""
    @ObservedObject var commonInitializePaymentViewModel = CommonInitializePaymentViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    @StateObject private var repeatingTask = RepeatingTask()
    @State private var showFailureScreen: Bool = false
    @State private var showSuccessSheet: Bool = false
    @State private var creditCardEmiOptionBool: Bool = false
    @State private var debitCardEmiOptionBool: Bool = false
    @State private var othersCardEmiOptionBool: Bool = false
    @State private var isWebViewClosedProgrammatically = false
    
    private var paymentOptionList: [PaymentMethod] {
        checkOutViewModel.paymentOptionList
    }
    private var currencySymbol: String{
        checkOutViewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
    }
    
    private func processPaymentOptions() {
        // updating booleans with enabled payment options
        for paymentMethod in paymentOptionList {
            if paymentMethod.brand == "CreditCardEMI" {
                creditCardEmiOptionBool = true
            }
            if paymentMethod.brand == "DebitCardEMI" {
                debitCardEmiOptionBool = true
            }
            if paymentMethod.brand == "CardlessEMI" {
                othersCardEmiOptionBool = true
            }
        }
    }
    
    
    var body: some View {
        VStack {
            // Header with back button and total amount
            PaymentHeaderView(
                title: "Choose EMI Option",
                itemCount: checkOutViewModel.sessionData?.paymentDetails.order?.items?.count ?? 0,
                totalPrice: checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                currencySymbol: currencySymbol,
                onBack: { presentationMode.wrappedValue.dismiss() }
            )
            Spacer()
            Divider()
            // Tab bar for switching screens
            HStack {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack {
                            Text(tabs[index])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedTab == index ? .green : .gray)
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(selectedTab == index ? .green : .clear)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 7)
            
            // Common Search and Filter Section
            HStack {
                searchField(placeholder: "Search for bank")
            }
            
            if(!isOthersTabSelected){
                HStack {
                    HStack {
                        Button(action: {
                            isFilteringNoCostEMI.toggle() // Toggle filter on tap
                        }) {
                            Text(isFilteringNoCostEMI ? "No Cost EMI x" : "No Cost EMI +")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isFilteringNoCostEMI ? .green : Color(hex: "#2D2B32"))
                                .padding(8)
                                .background(isFilteringNoCostEMI ? Color.green.opacity(0.2) : Color.white.opacity(0.2))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(isFilteringNoCostEMI ? Color.green : Color.gray, lineWidth: 1)
                                )
                        }
                        Spacer()
                    }
                    
                }
                .padding(.horizontal)
            }
            // Tab content view
            TabView(selection: $selectedTab) {
                if creditCardEmiOptionBool {
                    CreditCardView(
                        creditCardEmiOptions: creditCardEmiOptions,
                        searchText: $searchText,
                        selectedEMIOptions: $selectedEMIOptions,
                        navigateToDetails: $navigateToDetails,
                        isFilteringNoCostEMI: $isFilteringNoCostEMI,
                        allEmiPaymentOptions: allEmiPaymentOptions,
                        creditCardEmiOptionsWithTags: creditCardEmiOptionsWithTags
                    )
                    .tag(0)
                }
                
                if debitCardEmiOptionBool {
                    DebitCardView(
                        debitCardEmiOptions: debitCardEmiOptions,
                        searchText: $searchText,
                        selectedEMIOptions: $selectedEMIOptions,
                        navigateToDetails: $navigateToDetails,
                        isFilteringNoCostEMI: $isFilteringNoCostEMI,
                        allEmiPaymentOptions: allEmiPaymentOptions,
                        debitCardEmiOptionsWithTags: debitCardEmiOptionsWithTags
                    )
                    .tag(1)
                }
                
                if othersCardEmiOptionBool {
                    OthersView(
                        othersEmiOptions: othersEmiOptions,
                        searchText: $searchText,
                        selectedEMIOptions: $selectedEMIOptions,
                        navigateToDetails: $navigateToDetails,
                        isFilteringNoCostEMI: $isFilteringNoCostEMI,
                        showSuccesScreen: $showSuccessSheet,  // ✅ Pass binding correctly
                        showFailureScreen: $showFailureScreen,  // ✅ Pass binding correctly
                        isLoading: $isLoading,  // ✅ Pass binding correctly
                        selectedBank: $selectedBank,
                        repeatingTask: repeatingTask,
                        checkOutViewModel: checkOutViewModel,
                        commonInitializePaymentViewModel: commonInitializePaymentViewModel,
                        allEmiPaymentOptions: allEmiPaymentOptions,
                        othersEmiOptionsWithTags: othersEmiOptionsWithTags,
                        currencySymbol: currencySymbol
                    )
                    .tag(2)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .preferredColorScheme(.light)
            
        }.onAppear{
            if(allEmiPaymentOptions.isEmpty){
                let apiManager = APIManager()
                checkOutViewModel.getCheckoutSession(token: apiManager.getMainToken())
                repeatingTask.paymentViewModel = paymentViewModel
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    mapBanks(from: checkOutViewModel.paymentOptionList)
                    allEmiPaymentOptions = checkOutViewModel.paymentOptionList
                    self.processPaymentOptions()
                    isLoading = false
                }
            }
        }
        .onDisappear {
            repeatingTask.stopRepeatingTask()
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
        .onChange(of: selectedEMIOptions) { newOptions in
            if !newOptions.isEmpty {
                navigateToDetails = true
            }
        }
        .navigate(to: EMIDetailsView(emiOptions: selectedEMIOptions), when: $navigateToDetails)
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
        .onChange(of: selectedTab) { newValue in
            print("Switched to tab: \(tabs[newValue])")
            // If a tab is disabled, reset selectedTab to the next available tab:
            if (newValue == 0 && !creditCardEmiOptionBool) {
                selectedTab = debitCardEmiOptionBool ? 1 : (othersCardEmiOptionBool ? 2 : 0)
            } else if (newValue == 1 && !debitCardEmiOptionBool) {
                selectedTab = othersCardEmiOptionBool ? 2 : (creditCardEmiOptionBool ? 0 : 1)
            } else if (newValue == 2 && !othersCardEmiOptionBool) {
                selectedTab = creditCardEmiOptionBool ? 0 : (debitCardEmiOptionBool ? 1 : 2)
            }
            
            if(newValue == 2){
                isOthersTabSelected = true
            }else{
                isOthersTabSelected = false
            }
            // Handle data update based on the selected tab if needed
            // This is for the visibility of the filter for NO COST EMI
        }
    }
    
    private func searchField(placeholder: String) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            TextField(placeholder, text: $searchText)
                .font(.system(size: 12, weight: .regular))
                .padding(.top,10)
                .padding(.bottom,10)
                .onChange(of: searchText) { _ in
                    //filterBanks()
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
        .padding(.leading,10)
        .padding(.trailing,10)
        .padding(.vertical, 1)
    }
    
    private func mapBanks(from paymentMethods: [PaymentMethod]) {
        var creditCardEmiOptions: [PaymentMethod] = []
        var debitCardEmiOptions: [PaymentMethod] = []
        var othersEmiOptions: [PaymentMethod] = []
        
        var creditCardEmiOptionsWithTags: [PaymentMethod] = []
        var debitCardEmiOptionsWithTags: [PaymentMethod] = []
        var othersEmiOptionsWithTags: [PaymentMethod] = []
        
        // Group banks by id
        var groupedBanks = [String: [PaymentMethod]]()
        
        for paymentMethod in paymentMethods {
            guard let bankId = paymentMethod.id else { continue }
            groupedBanks[bankId, default: []].append(paymentMethod)
        }
        
        // Process grouped banks
        for (_, bankGroup) in groupedBanks {
            guard let bankWithLowestInterest = bankGroup.min(by: {
                ($0.emiMethod?.interestRate ?? Double.greatestFiniteMagnitude) <
                    ($1.emiMethod?.interestRate ?? Double.greatestFiniteMagnitude)
            }) else { continue }
            
            // Merge all unique tags
            let mergedTags = Array(Set(bankGroup.flatMap { $0.tags }))
            
            // Merge all offers
            let mergedOffers = bankGroup.flatMap { $0.applicableOffers ?? [] }
            
            // ✅ Create a **new instance** of PaymentMethod with merged tags & offers
            let updatedBank = PaymentMethod(
                id: bankWithLowestInterest.id,
                type: bankWithLowestInterest.type,
                brand: bankWithLowestInterest.brand,
                title: bankWithLowestInterest.title,
                typeTitle: bankWithLowestInterest.typeTitle,
                logoUrl: bankWithLowestInterest.logoUrl,
                instrumentTypeValue: bankWithLowestInterest.instrumentTypeValue,
                applicableOffers: mergedOffers, // ✅ Store merged offers
                emiMethod: bankWithLowestInterest.emiMethod
            )
            
            // Categorize based on EMI type
            if let brand = updatedBank.emiMethod?.brand {
                switch brand {
                case "CreditCardEMI":
                    creditCardEmiOptions.append(updatedBank)
                    if !mergedTags.isEmpty {
                        creditCardEmiOptionsWithTags.append(updatedBank)
                    }
                case "DebitCardEMI":
                    debitCardEmiOptions.append(updatedBank)
                    if !mergedTags.isEmpty {
                        debitCardEmiOptionsWithTags.append(updatedBank)
                    }
                default: // Cardless EMI or Others
                    othersEmiOptions.append(updatedBank)
                    if !mergedTags.isEmpty {
                        othersEmiOptionsWithTags.append(updatedBank)
                    }
                }
            }
        }
        
        // Assign processed lists
        self.creditCardEmiOptions = creditCardEmiOptions
        self.debitCardEmiOptions = debitCardEmiOptions
        self.othersEmiOptions = othersEmiOptions
        self.creditCardEmiOptionsWithTags = creditCardEmiOptionsWithTags
        self.debitCardEmiOptionsWithTags = debitCardEmiOptionsWithTags
        self.othersEmiOptionsWithTags = othersEmiOptionsWithTags
    }
    
    struct EMIBankOptionDataClass: Identifiable, Equatable {
        var id = UUID()
        var bankName: String
        var bankImage: String
        var bankBrand: String
        var bankInterestRate: Double
        var bankInstrumentTypeValue: String
    }
    
    struct CreditCardView: View {
        let creditCardEmiOptions: [PaymentMethod]
        @Binding var searchText: String
        @Binding var selectedEMIOptions: [PaymentMethod] // Binding for selected EMI options
        @Binding var navigateToDetails: Bool // Binding for navigation flag
        @Binding var isFilteringNoCostEMI: Bool // ✅ Now passed as a binding
        let allEmiPaymentOptions: [PaymentMethod] // Pass full EMI list
        let creditCardEmiOptionsWithTags: [PaymentMethod]
        
        var filteredOptions: [PaymentMethod] {
            var options = searchText.isEmpty ? creditCardEmiOptions : creditCardEmiOptions.filter {
                $0.emiMethod?.issuerTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            
            // ✅ Apply "No Cost EMI" filter if enabled
            if isFilteringNoCostEMI {
                options = creditCardEmiOptionsWithTags
            }
            
            return options
        }
        
        var body: some View {
            ZStack {
                Color(.systemGray6) // Grey background
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("All Banks")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#4F4D55"))
                                .padding(.leading, 15)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        BankListView(
                            title: "Credit Card EMI",
                            banks: filteredOptions,
                            selectedEMIOptions: $selectedEMIOptions, // Pass binding
                            navigateToDetails: $navigateToDetails, // Pass binding
                            allEmiPaymentOptions: allEmiPaymentOptions
                        )
                        
                        FooterView()
                            .padding(.top, 10)
                    }
                }
                .hideKeyboardOnTap()
            }
        }
    }
    
    struct DebitCardView: View {
        let debitCardEmiOptions: [PaymentMethod]
        @Binding var searchText: String
        @Binding var selectedEMIOptions: [PaymentMethod] // Binding for selected EMI options
        @Binding var navigateToDetails: Bool // Binding for navigation flag
        @Binding var isFilteringNoCostEMI: Bool // ✅ Now passed as a binding
        let allEmiPaymentOptions: [PaymentMethod] // Pass full EMI list
        let debitCardEmiOptionsWithTags: [PaymentMethod] // Pass full EMI list
        
        var filteredOptions: [PaymentMethod] {
            var options = searchText.isEmpty ? debitCardEmiOptions : debitCardEmiOptions.filter {
                $0.emiMethod?.issuerTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            
            // ✅ Apply "No Cost EMI" filter if enabled
            if isFilteringNoCostEMI {
                options = debitCardEmiOptionsWithTags
            }
            
            return options
        }
        
        var body: some View {
            ZStack {
                Color(.systemGray6) // Grey background
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("All Banks")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#4F4D55"))
                                .padding(.leading, 15)
                            Spacer()
                        }
                        .padding(.top, 10)
                        BankListView(
                            title: "Debit Card Options",
                            banks: filteredOptions,
                            selectedEMIOptions: $selectedEMIOptions, // Pass binding
                            navigateToDetails: $navigateToDetails, // Pass binding
                            allEmiPaymentOptions: allEmiPaymentOptions
                        )
                        
                        FooterView()
                            .padding(.top, 10)
                    }
                }
                .hideKeyboardOnTap()
            }
        }
    }
    
    struct OthersView: View {
        let othersEmiOptions: [PaymentMethod]
        @Binding var searchText: String
        @Binding var selectedEMIOptions: [PaymentMethod]
        @Binding var navigateToDetails: Bool
        @Binding var isFilteringNoCostEMI: Bool
        @Binding var showSuccesScreen: Bool
        @Binding var showFailureScreen: Bool
        @Binding var isLoading: Bool
        @Binding var selectedBank: PaymentMethod?
        @ObservedObject var repeatingTask: RepeatingTask  // ✅ Fix: Use @ObservedObject
        var checkOutViewModel: CheckoutViewModel
        var commonInitializePaymentViewModel: CommonInitializePaymentViewModel
        let allEmiPaymentOptions: [PaymentMethod]
        let othersEmiOptionsWithTags: [PaymentMethod]
        let currencySymbol: String
        
        
        
        var filteredOptions: [PaymentMethod] {
            var options = searchText.isEmpty ? othersEmiOptions : othersEmiOptions.filter {
                $0.emiMethod?.cardlessEmiProviderTitle?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            
            // ✅ Apply "No Cost EMI" filter if enabled
            if isFilteringNoCostEMI {
                options = othersEmiOptionsWithTags
            }
            
            return options
        }
        
        var body: some View {
            ZStack {
                Color(.systemGray6) // Grey background
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("All Banks")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#4F4D55"))
                                .padding(.leading, 15)
                            Spacer()
                        }
                        .padding(.top, 10)
                        OthersListView(
                            title: "Banks",
                            banks: filteredOptions,
                            selectedEMIOptions: $selectedEMIOptions,
                            navigateToDetails: $navigateToDetails,
                            showSuccessSheet: $showSuccesScreen,  // ✅ Pass binding
                            showFailureScreen: $showFailureScreen,
                            isLoading: $isLoading,
                            selectedBank: $selectedBank,
                            repeatingTask: repeatingTask,  // ✅ Fix: Use ObservedObject
                            checkOutViewModel: checkOutViewModel,
                            commonInitializePaymentViewModel: commonInitializePaymentViewModel,
                            allEmiPaymentOptions: allEmiPaymentOptions,
                            currencySymbol: currencySymbol
                            
                        )
                        
                        FooterView()
                            .padding(.top, 10)
                    }
                }
                .hideKeyboardOnTap()
            }
        }
    }
    
    struct BankListView: View {
        let title: String
        let banks: [PaymentMethod]
        @Binding var selectedEMIOptions: [PaymentMethod] // Binding for selected EMI options
        @Binding var navigateToDetails: Bool // Binding for navigation flag
        let allEmiPaymentOptions: [PaymentMethod] // Pass full EMI list
        
        var body: some View {
            VStack(alignment: .leading) {
                ScrollView {
                    ForEach(banks, id: \.id) { bank in
                        BankRow(bank: bank,allEmiPaymentOptions: allEmiPaymentOptions)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                handleBankSelection(bank)
                            }
                        if bank != banks.last {
                            Divider()
                        } else {
                            Spacer()
                        }
                    }
                    
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 10)
            .padding(.top, 10)
        }
        
        private func handleBankSelection(_ selectedBank: PaymentMethod) {
            guard let selectedBankId = selectedBank.id else {
                print("❌ Selected bank has no valid ID.")
                return
            }
            
            print("🔹 Selected Bank ID: \(selectedBankId)")
            
            // ✅ Get all instances of the selected bank (matching `id`)
            selectedEMIOptions = allEmiPaymentOptions
                .filter { $0.id == selectedBankId }
                .sorted {
                    let duration1 = $0.emiMethod?.duration ?? Int.max
                    let duration2 = $1.emiMethod?.duration ?? Int.max
                    
                    if duration1 == duration2 {
                        // 🔹 If durations are the same, sort by interest rate
                        return ($0.emiMethod?.interestRate ?? Double.greatestFiniteMagnitude) <
                            ($1.emiMethod?.interestRate ?? Double.greatestFiniteMagnitude)
                    }
                    return duration1 < duration2 // 🔹 Sort by increasing duration
                }
            
            print("✅ Found \(selectedEMIOptions.count) matching EMI options (sorted by duration):")
            for emi in selectedEMIOptions {
                print("👉 \(emi.title ?? "Unknown") - \(emi.emiMethod?.duration ?? 0) months - \(emi.emiMethod?.interestRate ?? 0)% interest")
            }
            
            // Navigate to EMI details screen
            //navigateToDetails = true
        }
        
    }
    
    
    
    struct BankRow: View {
        let bank: PaymentMethod
        let allEmiPaymentOptions: [PaymentMethod] // ✅ Full list of EMI options
        
        // ✅ Extract all tags from banks with the same `id`
        var allTags: [String] {
            let matchingBanks = allEmiPaymentOptions.filter { $0.id == bank.id }
            return Array(Set(matchingBanks.flatMap { $0.tags })) // Remove duplicates
        }
        
        // ✅ Find the lowest `effectiveInterestRate` among matching banks
        var lowestInterestRate: Double {
            let matchingBanks = allEmiPaymentOptions.filter { $0.id == bank.id }
            return matchingBanks.compactMap { $0.emiMethod?.interestRate }.min() ?? 0.00
        }
        
        var body: some View {
            HStack {
                bankImageView(bank: bank)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(bank.emiMethod?.issuerTitle ?? bank.emiMethod?.cardlessEmiProviderTitle ?? "")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#4F4D55"))
                            .padding(.leading,5)
                        
                        Spacer()
                    }
                    
                    // ✅ Display merged tags dynamically
                    if !allTags.isEmpty {
                        HStack {
                            ForEach(allTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 8))
                                    .padding(4)
                                    .background(Color.pink.opacity(0.1))
                                    .foregroundColor(.pink)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.pink, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                
                // ✅ Display the lowest effective interest rate dynamically
                Text("@\(String(format: "%.2f", lowestInterestRate)) p.a.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#4F4D55"))
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .background(Color.white)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.top, 2)
            .padding(.bottom, 2)
        }
    }
    
}

struct OtherRow: View {
    let bank: PaymentMethod
    @Binding var selectedBank: PaymentMethod?
    
    var body: some View {
        Button(action: {
            selectedBank = bank
        }) {
            HStack {
                bankImageView(bank: bank)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.leading, 15)
                
                Text(bank.emiMethod?.cardlessEmiProviderTitle ?? "")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#4F4D55"))
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: selectedBank == bank ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selectedBank == bank ? .green : .gray)
                    .font(.system(size: 22))
                    .padding(.trailing, 15)
            }
            .padding(.vertical, 10) // ✅ Ensures a good tap area
            .contentShape(Rectangle()) // ✅ Makes the entire row tappable
        }
        .buttonStyle(PlainButtonStyle()) // ✅ Removes default button animation
    }
}

struct OthersListView: View {
    let title: String
    let banks: [PaymentMethod]
    @Binding var selectedEMIOptions: [PaymentMethod]
    @Binding var navigateToDetails: Bool
    @Binding var showSuccessSheet: Bool // ✅ Fix: Make this a @Binding
    @Binding var showFailureScreen: Bool
    @Binding var isLoading: Bool
    @Binding var selectedBank: PaymentMethod?
    @ObservedObject var repeatingTask: RepeatingTask
    var checkOutViewModel: CheckoutViewModel
    var commonInitializePaymentViewModel: CommonInitializePaymentViewModel
    let allEmiPaymentOptions: [PaymentMethod]
    let currencySymbol: String
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(banks, id: \.id) { bank in
                    VStack{
                        OtherRow(bank: bank,selectedBank: $selectedBank)
                            .padding(.top, 5)
                            .onTapGesture {
                                
                            }
                        if selectedBank == bank {
                            Button(action: {
                                print("Proceed to pay \(currencySymbol) \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0") for \(bank.emiMethod?.cardlessEmiProviderTitle ?? "")")
                                handleBankSelection(bank)
                                
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
                        if bank != banks.last {
                            Divider()
                        } else {
                            Spacer()
                        }
                    }.background(selectedBank == bank ? Color.green.opacity(0.1) : Color.clear)
                }
                
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    private func handleBankSelection(_ selectedBank: PaymentMethod) {
        print("Proceed to pay \(checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0") for ")
        
        repeatingTask.startRepeatingTask(
            showSuccesScreen: $showSuccessSheet,
            showFailureScreen: $showFailureScreen,
            isLoading: $isLoading
        )
        commonInitializePaymentViewModel.postRequest(InstrumentTypeValue: selectedBank.instrumentTypeValue ?? "", isLoading: $isLoading, showFailureScreen: $showFailureScreen,screenName: "EMI_CARDLESS",cardlessEmiProvider: selectedBank.emiMethod?.cardlessEmiProviderValue ?? "")
    }
    
}

private func bankImageView(bank: PaymentMethod) -> some View {
    Group {
        if let imageURL = URL(string: bank.logoUrl ?? "") {
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

extension PaymentMethod {
    var tags: [String] {
        var tagsArray: [String] = []
        
        for offer in applicableOffers ?? [] {
            if case let .object(details) = offer {
                if details.discount?.type == "NoCostEmi" {
                    tagsArray.append("NO COST EMI")
                } else if details.discount?.type == "LowCostEmi" {
                    tagsArray.append("LOW COST EMI")
                }
            }
        }
        return tagsArray
    }
}




struct Bank : Equatable {
    let name: String
    let interestRate: String
    var tags: [String] = []
}


struct EMIOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            EMIOptionsView()
        }
    }
}
