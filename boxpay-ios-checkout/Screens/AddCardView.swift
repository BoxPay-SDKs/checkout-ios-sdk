//
//  AddCardView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 27/01/25.
//


import SwiftUI
import Foundation
import Combine
import AlertToast

@available(iOS 15.0, *)
struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    var onGoBackToApp: (() -> Void)?
    var emi: PaymentMethod? // ✅ Accept EMI object

    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var cardHolderName: String = ""
    @State private var cardBrand: String = ""
    
    @State private var isLoading = false
    
    @State private var isPayNowEnabled: Bool = false
    @State private var isCheckboxChecked: Bool = false
    @State private var showCvvInfo: Bool = false
    @State private var showRbiGuidelines: Bool = false
    @State private var isCardNumberValid: Bool = true
    @State private var isExpiryDateValid: Bool = true
    @State private var isCVVValid: Bool = true
    @State private var isCardHolderNameValid: Bool = true
    @State private var isCardHolderNameTypedOnce: Bool = false
    @State private var showFailureScreen: Bool = false
    @State private var showSuccessSheet: Bool = false
    @State private var showFieldErrorToast: Bool = false
    @State private var keyboardHeight: CGFloat = 0 // Tracks the keyboard height
    
    @State private var showWebView = false
    @State private var dynamicURL: String = ""
    
    @FocusState private var focusedField: FocusField? // Enum to track the focused field
    
    @ObservedObject var cardUrlViewModel = CardUrlViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @StateObject private var repeatingTask = RepeatingTask()
    private var currencySymbol: String{
        checkOutViewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
    }
    enum FocusField {
        case cardNumber, expiryDate, cvv, cardHolderName
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                // Header
                PaymentHeaderView(
                    title: "Card Payment",
                    itemCount: checkOutViewModel.sessionData?.paymentDetails.order?.items?.count ?? 0,
                    totalPrice: checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                    currencySymbol: currencySymbol,
                    onBack: { presentationMode.wrappedValue.dismiss() }
                )
                Divider()
                
                // Card Information Form
                ScrollView {
                    VStack(spacing: 15) {
                        if emi != nil {
                            EMIInfoRow(emi: emi, currencySymbol : currencySymbol)
                        }
                        cardNumberField
                        expiryAndCvvFields
                        cardHolderNameField
                        noteView
                        checkboxView
                        Spacer()
                    }.hideKeyboardOnTap()
                        .padding(.horizontal)
                        .background(Color.white.ignoresSafeArea()).preferredColorScheme(.light)
                }.hideKeyboardOnTap()
            }
            
            // Pay Now Button
            VStack {
                Spacer()
                payNowButton
                    .padding(.horizontal)
                    .padding(.bottom, keyboardHeight + 10) // Adjust padding for the keyboard
                    .transition(.move(edge: .bottom))
            }.animation(.bouncy, value: keyboardHeight)
            
        }.onAppear {
            setupKeyboardListeners()
            let apiManager = APIManager()
            checkOutViewModel.getCheckoutSession(token: apiManager.getMainToken())
            repeatingTask.paymentViewModel = paymentViewModel
        }
        .onDisappear {
            repeatingTask.stopRepeatingTask()
            removeKeyboardListeners()
        }
        .sheet(isPresented: $showCvvInfo) {
            if #available(iOS 16.0, *) {
                CVVInfoView(onGoBack: {
                    showCvvInfo = false
                })
                .presentationDetents([.height(320)]) // Optional: Set height dynamically
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            } // Show drag indicator
        }.onDisappear{
            showCvvInfo = false
        }
        .sheet(isPresented: $showRbiGuidelines) {
            if #available(iOS 16.0, *) {
                RBIGuidelinesView(onGoBack: {
                    showRbiGuidelines = false
                })
                .presentationDetents([.height(350)]) // Optional: Set height dynamically
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            } // Show drag indicator
        }.onDisappear{
            showRbiGuidelines = false
        }
        .onChange(of: cardUrlViewModel.redirectURL) { newURL in
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
        }.onAppear{
            isLoading = false
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
        }.onAppear {
            isLoading = false
        }
        .toast(isPresenting: $showFieldErrorToast, duration: 2, tapToDismiss: true, alert: {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: "Please fill all the fields")
           //AlertToast goes here
        }, onTap: {
           //onTap would call either if `tapToDismis` is true/false
           //If tapToDismiss is true, onTap would call and then dismis the alert
        }, completion: {
            showFieldErrorToast = false
           //Completion block after dismiss
        })
        
        .toast(isPresenting: $isLoading, duration: 100, tapToDismiss: false, alert: {
            AlertToast(type: .loading)
        }, onTap: {
        }, completion: {
            isLoading = false
        })
        .background(Color.white.ignoresSafeArea()).preferredColorScheme(.light)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var header: some View {
        HStack {
            Spacer().frame(width: 15)
            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
            }
            
            Text("Card Payment")
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            Text("100% SECURE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.green)
                .padding(2)
                .background(Color.gray.opacity(0.2))
            Spacer().frame(width: 10)
        }
        .padding(.bottom, 5)
        .background(Color.white)
    }
    
    
    
    struct EMIInfoRow: View {
        var emi: PaymentMethod?
        let currencySymbol: String


        var body: some View {
            if let emi = emi {
                HStack(spacing: 10) {
                    // ✅ Bank Logo
                    bankImageView(bank: emi)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .padding(.leading, 2)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text(emi.emiMethod?.issuerTitle ?? "Unknown Bank")
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()
                    
                    Text("|")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color.gray)
                        .padding(.trailing,5)
                    
                    // ✅ Bank Name
                    VStack(alignment: .leading, spacing: 2) {
                        

                        Text("\(emi.emiMethod?.duration ?? 0) months x \(currencySymbol)\(emi.emiMethod?.emiAmount ?? 0, specifier: "%.0f")")
                            .font(.system(size: 14))
                            .foregroundColor(.black)

                        Text("@\(emi.emiMethod?.interestRate ?? 0.0, specifier: "%.1f")% p.a.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
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
    }

    
    private var cardNumberField: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                TextField("Enter card number", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .cardNumber)
                    .onChange(of: cardNumber) { newValue in
                        // Remove any non-numeric characters and format with spaces
                        let formattedValue = formatCardNumber(newValue)
                        cardNumber = formattedValue
                        
                        // Update Pay Now button state
                        updatePayNowButtonState()
                        
                        // Check if the card number has 10 or more digits and trigger the API call
                        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
                        if cleanedCardNumber.count >= 10 && cleanedCardNumber.count <= 16 {
                            makeCardNetworkIdentificationCall(cardNumber: cleanedCardNumber) { brands, currBrand in
                                if let brands = brands, let currBrand = currBrand {
                                    DispatchQueue.main.async {
                                        cardBrand = currBrand
                                        print("Updated card network with brands: \(brands)" + currBrand)
                                    }
                                } else {
                                    print("Failed to fetch card network information")
                                }
                            }
                        } else {
                            cardBrand = ""
                        }
                    }
                    .onSubmit {
                        // Validate card number when the user submits or moves to the next field
                        isCardNumberValid = cardNumber.replacingOccurrences(of: " ", with: "").count == 16
                    }
                
                if cardBrand.isEmpty {
                    Image(systemName: "creditcard")
                        .foregroundColor(.gray)
                        .frame(width: 22, height: 20)
                } else if cardBrand == "VISA" {
                    Image(frameworkAsset: "visa_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                } else if cardBrand == "Mastercard" {
                    Image(frameworkAsset: "master_card_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                } else if cardBrand == "RUPAY" {
                    Image(frameworkAsset: "rupay_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                } else if cardBrand == "Maestro" {
                    Image(frameworkAsset: "maestro_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                } else if cardBrand == "AmericanExpress" {
                    Image(frameworkAsset: "american_express_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        (!isCardNumberValid && focusedField != .cardNumber && !cardNumber.isEmpty)
                        ? Color.red // Show error only when not focused and invalid
                        : (focusedField == .cardNumber
                           ? Color.green // When focused
                           : Color.gray), // Default state
                        lineWidth: 1
                    )
            )
            
            if !isCardNumberValid && focusedField != .cardNumber && !cardNumber.isEmpty {
                HStack {
                    Text("Oops! This card number is invalid")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading, 5)
                        .foregroundColor(Color(hex: "#E12121"))
                    Spacer()
                }
            }
        }
        .padding(.top, 1)
    }

    private var expiryAndCvvFields: some View {
        HStack(alignment: .top, spacing: 12) {
            // Expiry Date
            VStack(alignment: .leading, spacing: 8) {
                TextField("Expiry(MM/YY)", text: $expiryDate)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .expiryDate)
                    .onChange(of: expiryDate) { newValue in
                        // Format the expiry date to MM/YY
                        expiryDate = formatExpiryDate(newValue)
                        updatePayNowButtonState()
                    }
                    .onSubmit {
                        // Validate expiry date when the user submits or moves to the next field
                        let expiryDateRegex = #"^(0[1-9]|1[0-2])\/\d{2}$"#
                        if let _ = expiryDate.range(of: expiryDateRegex, options: .regularExpression) {
                            let components = expiryDate.split(separator: "/")
                            if components.count == 2,
                               let month = Int(components[0]),
                               let year = Int("20" + components[1]) {
                                let calendar = Calendar.current
                                let currentYear = calendar.component(.year, from: Date())
                                let currentMonth = calendar.component(.month, from: Date())
                                isExpiryDateValid = (year > currentYear) || (year == currentYear && month >= currentMonth)
                            } else {
                                isExpiryDateValid = false
                            }
                        } else {
                            isExpiryDateValid = false
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                (!isExpiryDateValid && focusedField != .expiryDate && !expiryDate.isEmpty)
                                ? Color.red // Show error only when not focused and invalid
                                : (focusedField == .expiryDate
                                   ? Color.green // When focused
                                   : Color.gray), // Default state
                                lineWidth: 1
                            )
                    )
                
                if !isExpiryDateValid && focusedField != .expiryDate && !expiryDate.isEmpty {
                    HStack {
                        Text("Oops! Expiry is invalid")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 5)
                            .foregroundColor(Color(hex: "#E12121"))
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
            
            // CVV
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    SecureField("Enter CVV", text: $cvv)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .cvv)
                        .onChange(of: cvv) { newValue in
                            cvv = formatCVV(newValue) // Limit CVV to 3 digits
                            updatePayNowButtonState()
                        }
                        .onSubmit {
                            // Validate CVV when the user submits or moves to the next field
                            isCVVValid = cvv.count == 3 && Int(cvv) != nil
                        }
                    
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                        .background(Color.clear) // Ensure background doesn’t interfere
                        .contentShape(Rectangle()) // Expands tap target
                        .onTapGesture {
                            showCvvInfo = true
                        }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            (!isCVVValid && focusedField != .cvv && !cvv.isEmpty)
                            ? Color.red // Show error only when not focused and invalid
                            : (focusedField == .cvv
                               ? Color.green // When focused
                               : Color.gray), // Default state
                            lineWidth: 1
                        )
                )
                
                if !isCVVValid && focusedField != .cvv && !cvv.isEmpty {
                    HStack {
                        Text("Oops! CVV is invalid")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 5)
                            .foregroundColor(Color(hex: "#E12121"))
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
            .alignmentGuide(.top) { _ in 0 }
        }
    }
    
    private func formatCardNumber(_ input: String) -> String {
        // Remove all non-numeric characters
        let cleanedInput = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Limit the input to 16 digits
        let trimmedInput = String(cleanedInput.prefix(16))
        
        // Add spaces after every 4 digits
        var formatted = ""
        for (index, character) in trimmedInput.enumerated() {
            if index != 0 && index % 4 == 0 {
                formatted += " " // Add a space
            }
            formatted.append(character)
        }
        
        return formatted
    }
    
    
    // Helper function to format expiry date
    private func formatExpiryDate(_ input: String) -> String {
        // Remove any non-digit characters
        let cleaned = input.filter { $0.isNumber }
        
        // Ensure the string is at most 4 characters long
        if cleaned.count <= 2 {
            return cleaned
        }
        
        // Format as MM/YY
        let month = String(cleaned.prefix(2))
        let year = String(cleaned.suffix(from: cleaned.index(cleaned.startIndex, offsetBy: 2)))
        return month + (year.isEmpty ? "" : "/\(year.prefix(2))")
    }
    
    private func formatCVV(_ input: String) -> String {
        // Allow only numeric characters and limit to 3 digits
        return String(input.prefix(3).filter { $0.isNumber })
    }
    
    private var cardHolderNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Enter name on the card", text: $cardHolderName)
                .focused($focusedField, equals: .cardHolderName)
                .onChange(of: cardHolderName) { _ in
                    // Update Pay Now button state as the user types
                    updatePayNowButtonState()
                }
                .onSubmit {
                    // Validate card holder name when the user submits or moves to the next field
                    isCardHolderNameValid = !cardHolderName.isEmpty
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            (!isCardHolderNameValid && focusedField != .cardHolderName && !cardHolderName.isEmpty)
                            ? Color.red // Show error only when not focused and invalid
                            : (focusedField == .cardHolderName
                               ? Color.green // When focused
                               : Color.gray), // Default state
                            lineWidth: 1
                        )
                )
            
            // Show error message only when the field is not focused and invalid
            if !isCardHolderNameValid && focusedField != .cardHolderName && !cardHolderName.isEmpty {
                HStack {
                    Text("Oops! Card holder name is invalid")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading, 5)
                        .foregroundColor(Color(hex: "#E12121"))
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
    }
    
    private var noteView: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
            Text("CVV will not be stored")
                .font(.system(size: 12, weight: .medium))
            Spacer()
        }
        .padding(3)
        .background(Color.green.opacity(0.2))
        .cornerRadius(4)
    }
    
    private var checkboxView: some View {
        HStack {
            Button(action: { isCheckboxChecked.toggle() }) {
                Image(systemName: isCheckboxChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isCheckboxChecked ? .white : .gray)
                    .background(isCheckboxChecked ? Color.green : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Text("Save this card as per RBI rules.")
                .font(.system(size: 14))
            Text("Know more")
                .font(.system(size: 12, weight: .semibold))
                .underline()
                .foregroundColor(.green)
                .onTapGesture {
                    showRbiGuidelines = true
                }
            Spacer()
        }
    }
    
    private var payNowButton: some View {
        Button(action: {
            if isPayNowEnabled {
                repeatingTask.startRepeatingTask(
                    showSuccesScreen: $showSuccessSheet,
                    showFailureScreen: $showFailureScreen,
                    isLoading: $isLoading
                )
                cardUrlViewModel.fetchCardPaymentUrl(
                    isLoading: $isLoading,
                    showFailureScreen: $showFailureScreen,
                    cardNumber: cardNumber,
                    cvv: cvv,
                    expiry: convertExpiryDate(expiryDate) ?? "",
                    cardHolderName: cardHolderName,
                    emi: emi,
                    saveCard: isCheckboxChecked
                )
            } else {
                showFieldErrorToast = true
            }
        }) {
            Text("Proceed to Pay " + currencySymbol + (checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isPayNowEnabled ? Color.green : Color.gray) // Toggle background color
                .cornerRadius(8)
        }

    }
    
    // MARK: - Update Pay Now Button State
    private func updatePayNowButtonState() {
        // Check if card number is exactly 16 digits
        isCardNumberValid = cardNumber.replacingOccurrences(of: " ", with: "").count == 16
        
        // Check if expiry date matches the MM/yy format
        let expiryDateRegex = #"^(0[1-9]|1[0-2])\/\d{2}$"#
        if expiryDate.range(of: expiryDateRegex, options: .regularExpression) != nil {
            let components = expiryDate.split(separator: "/")
            if components.count == 2,
               let month = Int(components[0]),
               let year = Int("20" + components[1]) { // Convert yy to yyyy

                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: Date())
                let currentMonth = calendar.component(.month, from: Date())

                // ✅ Expiry date must be in the future
                isExpiryDateValid = (year > currentYear) || (year == currentYear && month >= currentMonth)
            } else {
                isExpiryDateValid = false
            }
        } else {
            isExpiryDateValid = false
        }

        // Check if CVV is exactly 3 digits
        isCVVValid = cvv.count == 3 && Int(cvv) != nil
        isCardHolderNameValid = !cardHolderName.isEmpty
        
        // Update the Pay Now button state
        isPayNowEnabled = isCardNumberValid && isExpiryDateValid && isCVVValid && isCardHolderNameValid
    }

    
    
    // MARK: - Keyboard Listeners
    private func setupKeyboardListeners() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func convertExpiryDate(_ inputDate: String) -> String? {
        // Step 1: Create a date formatter for the input format (MM/YY)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/yy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        
        // Step 2: Parse the input string into a Date object
        if let date = inputFormatter.date(from: inputDate) {
            // Step 3: Create a formatter for the desired output format (YYYY-MM)
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Step 4: Format the date into the desired string format
            return outputFormatter.string(from: date)
        }
        
        // Return nil if the input date is invalid
        return nil
    }
}


func makeCardNetworkIdentificationCall(cardNumber: String, completion: @escaping ([String]?, String?) -> Void) {
    let apiManager = APIManager()
    let baseUrl = apiManager.getBaseURL() + "v0/checkout/sessions/"
    let token = apiManager.getMainToken()
    let urlString = "\(baseUrl)\(token)/bank-identification-numbers/\(cardNumber)"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil, nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let jsonData: [String: Any] = [:] // Your request body if needed
    request.httpBody = try? JSONSerialization.data(withJSONObject: jsonData)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors
        if let error = error {
            print("Error making API call: \(error.localizedDescription)")
            completion(nil, nil)
            return
        }
        
        // Handle the response
        guard let data = data else {
            print("No data received")
            completion(nil, nil)
            return
        }
        
        do {
            // Parse JSON
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let paymentMethod = jsonResponse["paymentMethod"] as? [String: Any],
               let currBrand = paymentMethod["brand"] as? String {
                
                let brands = [currBrand]
                print("Current brand: \(currBrand)")
                
                // Call updateCardNetwork with brands
                completion(brands, currBrand)
            } else {
                print("Invalid JSON structure")
                completion(nil, nil)
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            completion(nil, nil)
        }
    }
    
    task.resume()
}



struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            AddCardView()
        } else {
            // Fallback on earlier versions
        }
    }
}
