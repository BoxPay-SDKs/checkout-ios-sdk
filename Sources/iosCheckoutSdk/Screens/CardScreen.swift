//
//  CardScreen.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI

struct CardScreen : View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isCheckoutFocused : Bool
    
    // EMI Related params
    var durationNumber : Int? = nil
    var bankName : String? = nil
    var bankUrl : String? = nil
    var offerCode : String? = nil
    var emiAmount : String? = nil
    var interest  :String? = nil
    var cardType : String? = nil
    var emiIssuerBrand : String? = nil
    var onClickBack : () -> Void = {}
    
    @StateObject private var viewModel = CardViewModel()
    @ObservedObject private var analyticsViewModel : AnalyticsViewModel = AnalyticsViewModel()
    
    @State private var isCardNumberFocused = false
    @State private var isCardExpiryFocused = false
    @State private var isCardCvvFocused = false
    @State private var isCardNameFocused = false
    @State private var isCardNickNameFocused = false
    
    @State private var cardNumberTextInput = ""
    @State private var cardExpiryTextInput = ""
    @State private var cardCvvTextInput = ""
    @State private var cardNameTextInput = ""
    @State private var cardNickNameTextInput = ""
    
    @State private var cardNumberErrorText = ""
    @State private var cardExpiryErrorText = ""
    @State private var cardCvvErrorText = ""
    @State private var cardNameErrorText = ""
    @State private var isMethodEnabled = false
    @State private var maxCardNumberLength = 16
    @State private var maxCardCvvLength = 3
    
    @State private var isCardNumberValid : Bool? = nil
    @State private var isCardExpiryValid : Bool? = nil
    @State private var isCardCvvValid : Bool? = nil
    @State private var isCardNameValid : Bool? = nil
    
    @State private var cardImage : String? = "ic_default_card"
    @State private var issuerBrand = ""
    @State private var previousCardExpiryTextInput = ""
    @State private var allCardFieldsMandate = false
    
    @StateObject var fetchStatusViewModel = FetchStatusViewModel()
    
    @State private var sessionExpireScreen = false
    @State private var sessionCompleteScreen = false
    @State private var sessionFailedScreen = false
    @State private var errorReason = ""
    @State private var timeStamp = ""
    @State private var paymentUrl : String? = nil
    @State private var paymentHtmlString: String? = nil
    @State private var showWebView = false
    @State private var isCvvShowDetailsClicked = false
    @State private var isSavedCardKnowMoreClicked = false
    
    @State var itemsCount = 0
    @State var currencySymbol = ""
    @State var totalAmount = ""
    @State var brandColor = ""
    
    @State private var isSavedCardCheckBoxClicked = false
    
    var body: some View {
        VStack {
            if(viewModel.isLoading) {
                BoxpayLoaderView()
            } else {
                VStack{
                    HeaderView(
                        text: "Add a new card",
                        showDesc: false,
                        showSecure: true,
                        itemCount: 0,
                        currencySymbol: "",
                        amount: "",
                        onBackPress: {
                            if(durationNumber != nil) {
                                onClickBack()
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                    .padding(.bottom, 20)
                    ScrollView {
                        Spacer()
                        VStack(alignment: .leading) {
                            if(durationNumber != nil) {
                                HStack {
                                            // Left section (Bank logo + name)
                                    HStack {
                                        SVGImageView(url: URL(string:bankUrl ?? "")!, fallbackImage: "ic_netbanking_semi_bold")

                                        Text(bankName ?? "")
                                            .font(.custom("Poppins-SemiBold", size: 14))
                                            .foregroundColor(Color(hex: "#2D2B32"))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)


                                            // Divider
                                            Rectangle()
                                                .frame(width: 1, height: 40)
                                                .foregroundColor(Color(hex: "#E6E6E6"))

                                            // Right section (EMI details)
                                            VStack(alignment: .leading) {
                                                (
                                                    Text("\(durationNumber ?? 0) months x ")
                                                        .font(.custom("Poppins-SemiBold", size: 12)) +
                                                    Text(currencySymbol)
                                                        .font(.custom("Inter-SemiBold", size: 12)) +
                                                    Text(emiAmount ?? "")
                                                        .font(.custom("Poppins-SemiBold", size: 12))
                                                )
                                                    .foregroundColor(Color(hex: "#2D2B32"))

                                                Text("@\(interest ?? "")% p.a.")
                                                    .font(.custom("Poppins-Regular", size: 12))
                                                    .foregroundColor(Color(hex: "#2D2B32"))
                                            }
                                            .padding(14)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "#E6E6E6"), lineWidth: 1)
                                        )
                                        .padding(.bottom, 20)
                            }
                            FloatingLabelTextField(
                                    placeholder: "Card Number",
                                    text:$cardNumberTextInput,
                                    isValid: $isCardNumberValid,
                                    onChange: { newText in
                                        onCardNumberChange(newText)
                                    },
                                    isFocused: $isCardNumberFocused,
                                    keyboardType: .numberPad,
                                    onFocusEnd: onCardNumberBlur,
                                    trailingIcon: $cardImage,
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                            if(isCardNumberValid == false) {
                                Text("\(cardNumberErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        
                        }.padding(.bottom, 20)
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                FloatingLabelTextField(
                                    placeholder: "Expiry (MM/YY)",
                                    text: $cardExpiryTextInput,
                                    isValid: $isCardExpiryValid,
                                    onChange: { newTxt in
                                        handleCardExpiryTextChange(newTxt)
                                    },
                                    isFocused: $isCardExpiryFocused,
                                    keyboardType: .numberPad,
                                    onFocusEnd: handleCardExpiryBlur,
                                    trailingIcon: .constant(""),
                                    leadingIcon: .constant(""),
                                    isSecureText: .constant(false)
                                )
                                .fixedSize(horizontal: false, vertical: true) // Prevents expanding height
                                
                                if(isCardExpiryValid == false) {
                                    Text("\(cardExpiryErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                            .padding(.trailing, 6)
                            VStack(alignment: .leading) {
                                FloatingLabelTextField(
                                    placeholder: "CVV",
                                    text: $cardCvvTextInput,
                                    isValid: $isCardCvvValid,
                                    onChange: { newText in
                                        handleCardCvvTextChange(text: newText)
                                    },
                                    isFocused: $isCardCvvFocused,
                                    keyboardType: .numberPad,
                                    onFocusEnd: handleCardCvvBlur,
                                    trailingIcon: .constant("ic_question_mark"),
                                    leadingIcon: .constant(""),
                                    onClickIcon : {
                                        isCvvShowDetailsClicked = true
                                    },
                                    isSecureText: .constant(true)
                                )
                                .fixedSize(horizontal: false, vertical: true) // Prevents expanding height

                                if(isCardCvvValid == false) {
                                    Text("\(cardCvvErrorText)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#E12121"))
                                }
                            }
                            .padding(.leading, 6)
                        }
                        .padding(.bottom, 20)
                        VStack(alignment: .leading) {
                            FloatingLabelTextField(
                                placeholder: "Name on the Card",
                                text: $cardNameTextInput,
                                isValid: $isCardNameValid,
                                onChange: { newText in
                                    handleCardHolderNameTextChange(text: newText)
                                },
                                isFocused: $isCardNameFocused,
                                onFocusEnd: handleCardHolderNameBlur,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            )
                            if(isCardNameValid == false) {
                                Text("\(cardNameErrorText)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#E12121"))
                            }
                        }
                        if(!viewModel.shopperToken.isEmpty) {
                            FloatingLabelTextField(
                                placeholder: "Card Nickname (for easy identification)",
                                text: $cardNickNameTextInput,
                                isValid: .constant(true),
                                onChange: { newNickName in
                                    cardNickNameTextInput = newNickName
                                },
                                isFocused: $isCardNickNameFocused,
                                onFocusEnd: nil,
                                trailingIcon: .constant(""),
                                leadingIcon: .constant(""),
                                isSecureText: .constant(false)
                            ).padding(.top, 10)
                        }
                        HStack {
                            Image(frameworkAsset: "ic_info")
                                .frame(width: 12, height: 12)

                            Text("CVV will not be stored")
                                .font(.custom("Poppins-Medium", size: 12))
                                .foregroundColor(Color(hex: "#2D2B32"))
                                .padding(.leading, 4) // small spacing between icon and text
                        }
                        .padding(4) // padding inside the box
                        .frame(maxWidth: .infinity, alignment : .leading)
                        .background(Color(hex: "#E8F6F1"))
                        .cornerRadius(4)

                        if(!viewModel.shopperToken.isEmpty) {
                            HStack {
                                Toggle(isOn: $isSavedCardCheckBoxClicked) {
                                    Text("Save this card as per RBI rules.")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#2D2B32"))
                                        .padding(.leading, 4)
                                }
                                    .toggleStyle(CheckboxToggleStyle(enabledColor : Color(hex: brandColor)))
                                Button(action : {
                                    isSavedCardKnowMoreClicked = true
                                }) {
                                    Text("Know more")
                                        .font(.custom("Poppins-SemiBold", size: 12))
                                        .foregroundColor(Color(hex:brandColor))
                                        .padding(.leading, 2)
                                        .background(
                                            Rectangle()
                                            .frame(height: 1) // Adjust the thickness of the line
                                            .offset(y: 8)      // Adjust the position of the line
                                            .foregroundColor(Color(hex: brandColor))
                                        )
                                }
                            }
                            .padding(.top, 12)
                            .frame(maxWidth: .infinity, alignment : .leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    Button(action: {
                        if checkCardValid() && durationNumber == nil {
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "CardsScreen", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "CardsScreen", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "CardsScreen", "")
                            viewModel.initiateCardPostRequest(cardNumber: cardNumberTextInput.replacingOccurrences(of: "[^\\d]", with: "", options: .regularExpression), cardExpiry: cardExpiryTextInput, cardCvv: cardCvvTextInput, cardHolderName: cardNameTextInput, isSavedCardCheckBoxClicked: isSavedCardCheckBoxClicked, cardNickName: cardNickNameTextInput)
                        } else if (checkCardValid() && durationNumber != nil) {
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_CATEGORY_SELECTED.rawValue, "EMIScreen", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_METHOD_SELECTED.rawValue, "EMIScreen", "")
                            analyticsViewModel.callUIAnalytics(AnalyticsEvents.PAYMENT_INITIATED.rawValue, "EMIScreen", "")
                            viewModel.initiateEMICardPostRequest(cardNumber: cardNumberTextInput.replacingOccurrences(of: "[^\\d]", with: "", options: .regularExpression), cardExpiry: cardExpiryTextInput, cardCvv: cardCvvTextInput, cardHolderName: cardNameTextInput, cardType: cardType ?? "", offerCode: offerCode, duration: "\(durationNumber ?? 0)",isSavedCardCheckBoxClicked: isSavedCardCheckBoxClicked, cardNickName: cardNickNameTextInput)
                        }
                    }){
                        Text("Make Payment")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(allCardFieldsMandate ? Color(hex: brandColor) : Color.gray.opacity(0.5))
                            .cornerRadius(8)
                            .font(.custom("Poppins-Regular", size: 16))
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            Task {
                itemsCount = await viewModel.checkoutManager.getItemsCount()
                currencySymbol = await viewModel.checkoutManager.getCurrencySymbol()
                totalAmount = await viewModel.checkoutManager.getTotalAmount()
                brandColor = await viewModel.checkoutManager.getBrandColor()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(viewModel.$cardResponse.compactMap { $0 }) { cardResponse in
            updateCardInfo(with: cardResponse)
        }
        .onReceive(viewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .onReceive(fetchStatusViewModel.$actions.compactMap{$0},perform: handlePaymentAction)
        .bottomSheet(isPresented: $sessionExpireScreen) {
            SessionExpireScreen(
                brandColor: brandColor,
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
            },brandColor: brandColor)
        }
        .bottomSheet(isPresented: $sessionCompleteScreen) {
            GeneralSuccessScreen(transactionID: viewModel.transactionId, date: StringUtils.formatDate(from:timeStamp, to: "MMM dd, yyyy"), time: StringUtils.formatDate(from : timeStamp, to: "hh:mm a"), totalAmount: totalAmount,currencySymbol: currencySymbol, onDone: {
                isCheckoutFocused = true
                sessionCompleteScreen = false
//                presentationMode.wrappedValue.dismiss()
            },brandColor: brandColor)
        }
        .sheet(isPresented: $showWebView) {
            WebView(
                url: paymentUrl,
                htmlString: paymentHtmlString,
                onDismiss: {
                    showWebView = false
                    fetchStatusViewModel.startFetchingStatus(methodType: "Card")
                }
            )
        }
        .bottomSheet(isPresented: $isCvvShowDetailsClicked) {
            CVVInfoView(onGoBack: {
                isCvvShowDetailsClicked = false
            },brandColor: brandColor)
        }
        .bottomSheet(isPresented: $isSavedCardKnowMoreClicked) {
            SavedCardKnowMore(onGoBack: {
                isSavedCardKnowMoreClicked = false
            },brandColor: brandColor)
        }
    }
    
    private func updateCardInfo(with response: CardInfoResponse) {
        isMethodEnabled = response.methodEnabled
        issuerBrand = response.paymentMethod.brand ?? ""
        
        // Update card image based on the brand
        switch issuerBrand {
        case "VISA":
            cardImage = "ic_visa"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        case "Mastercard":
            cardImage = "ic_mastercard"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        case "RUPAY":
            cardImage = "ic_rupay"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        case "AmericanExpress":
            cardImage = "ic_amex"
            maxCardCvvLength = 4
            maxCardNumberLength = 15
        case "Maestro":
            cardImage = "ic_maestro"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        default:
            cardImage = "ic_default_card"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        }
    }
    
    func onCardNumberChange(_ text: String) {
        if text.isEmpty {
            cardNumberTextInput = ""
            isCardNumberValid = nil
            return
        }
        
        // Remove all non-digit characters
        let cleaned = text.replacingOccurrences(of: "[^\\d]", with: "", options: .regularExpression)

        // Limit to maxCardNumberLength digits
        let limited = String(cleaned.prefix(maxCardNumberLength))
        
        // Format in groups of 4 digits
        let formatted = limited.chunked(into: 4).joined(separator: " ")
        cardNumberTextInput = formatted

        // Validation and fetching based on digit count
        if limited.count > 10 {
            viewModel.fetchCardInfo(limited)
        } else {
            cardImage = "ic_default_card"
            maxCardCvvLength = 3
            maxCardNumberLength = 16
        }
        allCardFieldsMandate = checkCardValid()
    }



    func onCardNumberBlur() {
        let cleaned = cardNumberTextInput.replacingOccurrences(of: " ", with: "")
        
        // Check the cleaned length based on the card type (Max length check for cards)
        let cleanedLength = maxCardNumberLength

        // Determine the error message based on the cleaned card number length
        cardNumberErrorText = cleaned.isEmpty
            ? "Required"
            : (cleaned.count < cleanedLength && isMethodEnabled)
                ? "This card number is invalid"
        : (isCardNumberValid == false)
            ? "This card number is invalid"
            : (!isMethodEnabled)
                ? "This card is not supported for the payment"
                : "test reason"  // Replace with other conditions if needed

        // Set the validity flag after checking the card number length and Luhn check
        isCardNumberValid = cleaned.count >= cleanedLength &&
                            isMethodEnabled &&
                            isValidCardNumberByLuhn(cleaned)

        // Trigger UI updates and set the focus to false after validation
        isCardNumberFocused = false
    }


    private func isValidCardNumberByLuhn(_ number: String) -> Bool {
        guard number.count >= 13 else { return false }
        var sum = 0
        var isSecond = false

        for digit in number.reversed() {
            guard let d = Int(String(digit)) else { continue }
            var val = d
            if isSecond { val *= 2 }
            sum += val / 10
            sum += val % 10
            isSecond.toggle()
        }

        return sum % 10 == 0
    }

    func handleCardExpiryTextChange(_ text: String) {
        if text.isEmpty {
            cardExpiryTextInput = ""
            return
        }
        
        isCardExpiryValid = nil

        // Remove all non-digit characters
        let cleaned = text.replacingOccurrences(of: "[^\\d]", with: "", options: .regularExpression)

        var limited = String(cleaned.prefix(4))
        
        var formatted = ""

        // Handle case when user enters only 1 digit
        if limited.count == 1 {
            let firstDigit = Int(limited) ?? 0
            if firstDigit >= 2 {
                // Auto prepend 0 when first digit is >= 2 (e.g., '2' becomes '02/')
                formatted = "0\(firstDigit)/"
                limited = "0\(firstDigit)"
            } else {
                // Allow single '0' or '1' as valid for first digit
                formatted = limited
            }
        } else if limited.count == 2 {
            let month = Int(limited) ?? 0
            if month == 0 {
                // Reset if the month starts with '00'
                formatted = ""
                limited = ""
            } else if month > 12 {
                // Auto-correct months greater than 12 (e.g., '13' becomes '01/')
                let firstDigit = String(limited.prefix(1))
                formatted = "0\(firstDigit)/"
                limited = "0\(firstDigit)"
            } else {
                // Valid month, append slash after 2 digits
                formatted = limited + "/"
            }
        } else if limited.count > 2 {
            // Handle full MM/YY format, adding the slash automatically after two digits
            let month = limited.prefix(2)
            let year = limited.suffix(from: limited.index(limited.startIndex, offsetBy: 2))
            formatted = "\(month)/\(year)"
        }

        // Now handle deletion of slash correctly
        if text.count < cardExpiryTextInput.count {
            // If the user is deleting, ensure we handle slash deletion too
            if formatted.last == "/" {
                // If slash is the last character, remove it
                formatted.removeLast()
            }
        }

        cardExpiryTextInput = formatted
        allCardFieldsMandate = checkCardValid()
    }





    // MARK: - Handle Card Expiry Blur
    func handleCardExpiryBlur() {
        let cleaned = cardExpiryTextInput.replacingOccurrences(of: " ", with: "")
        cardExpiryErrorText = cleaned.isEmpty ? "Required" : (cleaned.count < 5 || isCardExpiryValid == false) ? "Expiry is invalid" : ""
        isCardExpiryValid = !(cleaned.count < 5 || isCardExpiryValid == false)
        isCardExpiryFocused = false
    }

    // MARK: - Handle Card CVV Blur
    func handleCardCvvBlur() {
        let cleaned = cardCvvTextInput.replacingOccurrences(of: " ", with: "")
        cardCvvErrorText = cleaned.isEmpty ? "Required" : (cleaned.count < maxCardCvvLength) ? "CVV is invalid" : ""
        isCardCvvValid = !(cleaned.count < maxCardCvvLength)
        isCardCvvFocused = false
    }

    // MARK: - Handle Card Holder Name Blur
    func handleCardHolderNameBlur() {
        let cleaned = cardNameTextInput.replacingOccurrences(of: " ", with: "")
        cardNameErrorText = cleaned.isEmpty ? "Required" : ""
        isCardNameValid = !cleaned.isEmpty
        isCardNameFocused = false
    }

    // MARK: - Handle Card CVV Text Change
    func handleCardCvvTextChange(text: String) {
        var updatedText = text
        if updatedText.count > maxCardCvvLength {
            updatedText = String(updatedText.prefix(maxCardCvvLength))
        }
        cardCvvTextInput = updatedText
        
        if updatedText.isEmpty {
            cardCvvErrorText = "Required"
            isCardCvvValid = false
        } else {
            cardCvvErrorText = ""
            isCardCvvValid = true
        }
        allCardFieldsMandate = checkCardValid()
    }

    // MARK: - Handle Card Holder Name Text Change
    func handleCardHolderNameTextChange(text: String) {
        cardNameTextInput = text
        if !text.isEmpty {
            cardNameErrorText = ""
            isCardNameValid = true
        }
        allCardFieldsMandate = checkCardValid()
    }
    
    func checkCardValid() -> Bool {
        var cleaned = 0
        if(maxCardNumberLength == 16) {
            cleaned = 19
        } else {
            cleaned = 18
        }
//        if let durationNumber = durationNumber, !durationNumber.isEmpty {
//            if cardNumberError || cardExpiryError || cardCvvError || cardHolderNameError ||
//                (cardNumberText?.count ?? 0) != maxCardNumberLength ||
//                (cardExpiryText?.count ?? 0) != 5 ||
//                (cardCvvText?.count ?? 0) != maxCvvLength ||
//                (cardHolderNameText?.count ?? 0) < 1 ||
//                !cardNumberValid || !emiIssuerExist {
//                
//                setCardValid(false)
//            } else {
//                setCardValid(true)
//            }
//        } else {
        if (isCardNumberValid == false || isCardExpiryValid == false || isCardCvvValid == false || isCardNameValid == false ||
            cardNumberTextInput.count != cleaned ||
            cardExpiryTextInput.count != 5 ||
            cardCvvTextInput.count != maxCardCvvLength ||
            cardNameTextInput.count < 1) {
                return false
            } else {
            return true
            }
//        }
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
            case .openQRUrl(url: let url):
                // no operation
                break
            }
        }
    }
}
