//
//  AddCardView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 27/01/25.
//


import SwiftUI
import Foundation
import Combine

@available(iOS 15.0, *)
struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    var onGoBackToApp: (() -> Void)?
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var cardHolderName: String = ""
    @State private var cardBrand: String = ""
    
    @State private var isLoading = false
    
    @State private var isPayNowEnabled: Bool = false
    @State private var isCheckboxChecked: Bool = false
    @State private var showCvvInfo: Bool = false
    @State private var isCardNumberValid: Bool = true
    @State private var isExpiryDateValid: Bool = true
    @State private var isCVVValid: Bool = true
    @State private var isCardHolderNameValid: Bool = true
    @State private var isCardHolderNameTypedOnce: Bool = false
    @State private var showFailureScreen: Bool = false
    @State private var showSuccessSheet: Bool = false
    @State private var keyboardHeight: CGFloat = 0 // Tracks the keyboard height
    
    @State private var showWebView = false
    @State private var dynamicURL: String = ""
    
    @FocusState private var focusedField: FocusField? // Enum to track the focused field
    
    @ObservedObject var cardUrlViewModel = CardUrlViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    private let repeatingTask = RepeatingTask()
    
    enum FocusField {
        case cardNumber, expiryDate, cvv, cardHolderName
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                // Header
                header
                
                // Card Information Form
                ScrollView {
                    Divider().frame(height: 1)
                    VStack(spacing: 13) {
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
            
            if isLoading { // Check if loader is active
                Color.black.opacity(0.5) // Background overlay
                    .ignoresSafeArea() // Cover the entire screen
                
                VStack { // Loader VStack
                    ProgressView() // Circular loader
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2) // Adjust loader size
                    
                    Text("Loading, please wait...") // Loading text
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.top, 10)
                } // End of Loader VStack
            }
            
        }.onAppear {
            setupKeyboardListeners()
            repeatingTask.paymentViewModel = paymentViewModel
        }
        .onDisappear {
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
        .onChange(of: cardUrlViewModel.redirectURL) { newURL in
            // Update state variables when redirectURL changes
            if let url = newURL, !url.isEmpty {
                dynamicURL = url
                showWebView = true  // Show WebView when URL is set
            }
        }
        .sheet(isPresented: $showWebView) {
            if let validURL = URL(string: dynamicURL) {
                WebView(
                    url: validURL,
                    onDismiss: { showWebView = false } // Close WebView on condition
                )
            } else {
                Text("Invalid URL") // Show error if URL is invalid
            }
        }
        .sheet(isPresented: $showFailureScreen) {
            if #available(iOS 16.0, *) {
                PaymentFailureScreen(
                    onRetryPayment: {
                        print("Retry Payment action from sheet")
                        showFailureScreen = false
                    },
                    onReturnToPaymentOptions: {
                        showFailureScreen = false
                        dismiss()
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
                    
                    // Close the success screen
                    DismissManager.shared.dismiss()
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
                        }else{
                            cardBrand = ""
                        }
                    }
                if cardBrand.isEmpty {
                    Image(systemName: "creditcard")
                        .foregroundColor(.gray)
                        .frame(width: 22, height: 20)
                } else if(cardBrand == "VISA") {
                    Image(frameworkAsset: "visa_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }else if(cardBrand == "Mastercard") {
                    Image(frameworkAsset: "master_card_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }else if(cardBrand == "RUPAY") {
                    Image(frameworkAsset: "rupay_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }else if(cardBrand == "Maestro") {
                    Image(frameworkAsset: "maestro_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }else if(cardBrand == "AmericanExpress") {
                    Image(frameworkAsset: "american_express_logo")
                        .resizable()
                        .frame(width: 30, height: 20)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        (!isCardNumberValid && !cardNumber.isEmpty)
                        ? Color.red // Highest priority for invalid input
                        : (focusedField == .cardNumber
                           ? Color.green // When focused and valid
                           : Color.gray), // Default state
                        lineWidth: 1
                    )
            )
            if(!isCardNumberValid && cardNumber != ""){
                HStack {
                    Text("Oops! This card number invalid")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading,5)
                        .foregroundColor(Color(hex: "#E12121"))
                    Spacer()
                }
            }
        }
        .padding(.top, 10)
    }
    
    
    private var expiryAndCvvFields: some View {
        HStack(alignment: .top, spacing: 12) {
            // Expiry Date
            VStack(alignment: .leading, spacing: 8) {
                TextField("MM/YY", text: $expiryDate)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .expiryDate)
                    .onChange(of: expiryDate) { newValue in
                        // Format the expiry date to MM/YY
                        expiryDate = formatExpiryDate(newValue)
                        updatePayNowButtonState()
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                (!isExpiryDateValid && !expiryDate.isEmpty)
                                ? Color.red // Highest priority for invalid input
                                : (focusedField == .expiryDate
                                   ? Color.green // When focused and valid
                                   : Color.gray), // Default state
                                lineWidth: 1
                            )
                    )
                
                if (!isExpiryDateValid && expiryDate != "") {
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
                    
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showCvvInfo = true
                        }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            (!isCVVValid && !cvv.isEmpty)
                            ? Color.red // Highest priority for invalid input
                            : (focusedField == .cvv
                               ? Color.green // When focused and valid
                               : Color.gray), // Default state
                            lineWidth: 1
                        )
                )
                
                if (!isCVVValid && cvv != "") {
                    
                    HStack {
                        Text("Oops! CVV is invalid")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.leading, 5)
                            .foregroundColor(Color(hex: "#E12121"))
                            .lineLimit(1)
                        Spacer()
                    }
                }
            } .alignmentGuide(.top) { _ in 0 }
            
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
                    isCardHolderNameTypedOnce = true
                    updatePayNowButtonState()
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            (!isCardHolderNameValid && !cardHolderName.isEmpty)
                            ? Color.red // Highest priority for invalid input
                            : (focusedField == .cardHolderName
                               ? Color.green // When focused and valid
                               : Color.gray), // Default state
                            lineWidth: 1
                        )
                )
            
            if(!isCardHolderNameValid && isCardHolderNameTypedOnce){
                HStack {
                    Text("Oops! Card holder name is invalid")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.leading,5)
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
            Spacer()
        }
    }
    
    private var payNowButton: some View {
        Button(action: {
            repeatingTask.startRepeatingTask(showSuccesScreen: $showSuccessSheet, showFailureScreen: $showFailureScreen, repeatingTask: repeatingTask, isLoading: $isLoading)
            cardUrlViewModel.fetchCardPaymentUrl(isLoading: $isLoading, showFailureScreen: $showFailureScreen, cardNumber: cardNumber, cvv: cvv, expiry: convertExpiryDate(expiryDate) ?? "" , cardHolderName: cardHolderName)
        }) {
            Text("Pay Now")
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
        isExpiryDateValid = expiryDate.range(of: expiryDateRegex, options: .regularExpression) != nil
        
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


class CardUrlViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var redirectURL: String?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCardPaymentUrl(isLoading: Binding<Bool>,showFailureScreen : Binding<Bool>, cardNumber: String, cvv: String, expiry: String, cardHolderName: String) {
        isLoading.wrappedValue = true
        let apiManager = APIManager()
        guard let url = URL(string: "\(apiManager.getBaseURL())v0/checkout/sessions/\(apiManager.getMainToken())") else {
            errorMessage = "Invalid URL"
            isLoading.wrappedValue = false
            showFailureScreen.wrappedValue = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Request-Id")
        request.addValue("iOS SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")
        
        // Build the request body using Codable structs
        let requestBody = RequestBody(
            browserData: BrowserData(
                screenHeight: "2324",
                screenWidth: "1080",
                acceptHeader: "application/json",
                userAgentHeader: "Mozilla/5.0 (Linux; Android 13; V2055 Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6723.86 Mobile Safari/537.36",
                browserLanguage: "en_US",
                ipAddress: "null",
                colorDepth: 24,
                javaEnabled: true,
                timeZoneOffSet: 330,
                packageId: "com.boxpay.checkout.demoapp"
            ),
            instrumentDetails: InstrumentDetails(
                type: "card/plain",
                card: Card(
                    number: cardNumber,
                    expiry: expiry,
                    cvc: cvv,
                    holderName: cardHolderName
                )
            ),
            shopper: ShopperCardView(
                firstName: "Nitish",
                lastName: "Arora",
                gender: nil,
                phoneNumber: "918556050340",
                email: "nitish.arora@boxpay.tech",
                uniqueReference: "123xyz123",
                dateOfBirth: "2024-11-14T10:31:00Z",
                panNumber: "FONPV5455R"
            ),
            deviceDetails: DeviceDetails(
                browser: "vivo",
                platformVersion: "13",
                deviceType: "vivo",
                deviceName: "vivo",
                deviceBrandName: "V2055"
            )
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
            errorMessage = "Failed to encode request data"
            isLoading.wrappedValue = false
            showFailureScreen.wrappedValue = true
            return
        }
        
        // Log the request body for debugging
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        // Perform the network request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("HTTP Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: APIResponseCardView.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    showFailureScreen.wrappedValue = true
                case .finished:
                    print("Request finished successfully")
                }
            }, receiveValue: { [weak self] response in
                self?.statusMessage = response.status.reason
                self?.redirectURL = response.actions.first?.url // Update the redirectURL
                print("Status: \(response.status.reason)")
                print("Redirect URL: \(response.actions.first?.url ?? "Not available")")
            })
            .store(in: &cancellables)
    }
    
    private func generateRandomAlphanumericString(length: Int) -> String {
        let charPool = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        return String((0..<length).compactMap { _ in charPool.randomElement() })
    }
}


// MARK: - Codable Structs
struct RequestBody: Codable {
    let browserData: BrowserData
    let instrumentDetails: InstrumentDetails
    let shopper: ShopperCardView
    let deviceDetails: DeviceDetails
}

struct BrowserData: Codable {
    let screenHeight: String
    let screenWidth: String
    let acceptHeader: String
    let userAgentHeader: String
    let browserLanguage: String
    let ipAddress: String
    let colorDepth: Int
    let javaEnabled: Bool
    let timeZoneOffSet: Int
    let packageId: String
}

struct InstrumentDetails: Codable {
    let type: String
    let card: Card
}

struct Card: Codable {
    let number: String
    let expiry: String
    let cvc: String
    let holderName: String
}

struct ShopperCardView: Codable {
    let firstName: String
    let lastName: String
    let gender: String?
    let phoneNumber: String
    let email: String
    let uniqueReference: String
    let dateOfBirth: String
    let panNumber: String
}

struct DeviceDetails: Codable {
    let browser: String
    let platformVersion: String
    let deviceType: String
    let deviceName: String
    let deviceBrandName: String
}

struct APIResponseCardView: Codable {
    let transactionId: String
    let transactionTimestamp: String
    let status: StatusCardView
    let actions: [ActionCardView]
    
    struct StatusCardView: Codable {
        let operation: String
        let status: String
        let reason: String
        let reasonCode: String
    }
    
    struct ActionCardView: Codable {
        let method: String
        let url: String
        let type: String
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
