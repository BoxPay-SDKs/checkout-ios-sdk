import SwiftUI
import Foundation


extension Image {
    // Helper to load images from the framework's assets catalog
    init(frameworkAsset name: String) {
        let bundle = Bundle(for: TestClass.self) // Any class from framework would work
        self.init(name, bundle: bundle)
    }
}

public struct MainCheckoutSheet: View {
    @Environment(\.presentationMode) var presentationMode
    // Access the presentation mode
    @StateObject private var viewModel = CheckoutViewModel()
    private let token: String // Token to be passed into the view
    private var orderItems: [OrderItem] {
        viewModel.sessionData?.paymentDetails.order?.items ?? []
    }
    private var paymentOptionList: [PaymentMethod] {
        viewModel.paymentOptionList
    }
    
    @State private var upiAvailable = false
    @State private var upiCollectMethod = false
    @State private var upiIntentMethod = false
    @State private var upiQRMethod = false
    
    @State private var cardsMethod = false
    @State private var walletMethods = false
    @State private var netBankingMethods = false
    @State private var emiMethod = false
    @State private var bnplMethod = false
    
    var dynamicPaymentOptions: [PaymentOption] {
        PaymentOption.allOptions(
            cardsMethod: cardsMethod,
            walletMethods: walletMethods,
            netBankingMethods: netBankingMethods,
            emiMethod: emiMethod,
            bnplMethod: bnplMethod
        )
    }
    
    
    // Custom initializer to accept the token
    public init(token: String) {
        self.token = token
    }
    
    
    private func processPaymentOptions() {
        for paymentMethod in paymentOptionList {
            if paymentMethod.title == "Upi" {
                if paymentMethod.type == "UpiCollect" {
                    upiCollectMethod = true
                    upiAvailable = true
                }
                if paymentMethod.type == "UpiIntent" {
                    upiIntentMethod = true
                    upiAvailable = true
                }
                if paymentMethod.type == "UpiQr" {
                    upiQRMethod = true
                    upiAvailable = true
                }
            }
            if paymentMethod.type == "Card" {
                cardsMethod = true
            }
            if paymentMethod.type == "Wallet" {
                walletMethods = true
            }
            if paymentMethod.type == "Emi" {
                emiMethod = true
            }
            if paymentMethod.type == "BuyNowPayLater" {
                bnplMethod = true
            }
            if paymentMethod.type == "NetBanking" {
                netBankingMethods = true
            }
        }
    }
    
    
    public var body: some View {
        
        VStack(spacing: 12) {
            
            HStack {
                Spacer()
                    .frame(width: 15)
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                    .frame(width: 15)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Payment Details")
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack(spacing: 3) {
                        Text(String(viewModel.sessionData?.paymentDetails.order?.items.count ?? 0) + " Items · Total:")
                            .font(.system(size: 12, weight: .regular))
                        Text("₹" + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                            .font(.system(size: 12, weight: .bold)).underline()
                    }
                }
                Spacer()
                Text("100% SECURE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .padding(2)
                    .background(Color.gray.opacity(0.2))
                Spacer()
                    .frame(width: 10)
            }
            
            ScrollView { // Wrap the entire content inside ScrollView
                
                VStack(spacing: 12) {
                    
                    Divider().frame(height: 2)
                    
                    // Address Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading)
                        HStack {
                            Image(frameworkAsset: "add_green")
                                .foregroundColor(.green)
                            Text("Add new address")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                    }
                    
                    // UPI Section - Changed "Add new UPI id" to match the "Add new address" style
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pay by any UPI App")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading)
                        
                        // "Add new UPI ID" card
                        VStack(alignment: .leading, spacing: 8) {
                            
                            // HStack for Images and Text
                            HStack(spacing: 30) { // Add custom spacing between images
                                VStack {
                                    Image(frameworkAsset: "gpay_upi_logo")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text("GPay") // Text below the image
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                VStack {
                                    Image(frameworkAsset: "phonepe")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text("PhonePe") // Text below the image
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                VStack {
                                    Image(frameworkAsset: "paytm_upi_logo")
                                        .resizable()
                                        .frame(width: 50, height: 40)
                                    Text("Paytm") // Text below the image
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            Spacer()
                            Divider()
                            Spacer()
                            HStack {
                                Image(frameworkAsset: "add_green")
                                    .foregroundColor(.green)
                                Text("Add new UPI ID")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.green)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                    }
                    
                    // More Payment Options - Inside a large card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("More Payment Options")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading)
                        
                        // Container for all options inside a large card
                        VStack(spacing: 0) {
                            ForEach(dynamicPaymentOptions.indices, id: \.self) { index in
                                VStack(spacing: 0) {
                                    HStack(alignment: .center) {
                                        // Load custom images from Media.xcassets
                                        Image(frameworkAsset: dynamicPaymentOptions[index].imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20) // Ensure consistent icon size
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(dynamicPaymentOptions[index].title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .lineLimit(1)
                                            
                                            Text(dynamicPaymentOptions[index].subTitle)
                                                .font(.system(size: 10, weight: .regular))
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .frame(width: 20, height: 20)
                                    }
                                    .padding(.vertical)
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    
                                    // Add divider only between rows, not after the last row
                                    if index < dynamicPaymentOptions.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Order Summary")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.leading)
                            VStack(alignment: .leading, spacing: 8) {
                                HStack{
                                    Text("Price Details")
                                        .font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                    Text("₹" + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                                        .font(.system(size: 14, weight: .semibold))
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                VStack {
                                    if orderItems.isEmpty {
                                        Text("Loading items...")
                                            .font(.system(size: 14, weight: .regular))
                                    } else {
                                        ItemsListView(items: orderItems)
                                    }
                                }.background(Color.white)
                                
                                HStack{
                                    Text("Sub Total")
                                        .font(.system(size: 14, weight: .regular))
                                    Spacer()
                                    Text("₹" + (viewModel.sessionData?.paymentDetails.order?.originalAmountLocaleFull ?? "0"))
                                    .font(.system(size: 14, weight: .regular))                        }
                                
                                HStack{
                                    Text("Shipping Charges")
                                        .font(.system(size: 14, weight: .regular))
                                    Spacer()
                                    Text("₹" + (viewModel.sessionData?.paymentDetails.order?.shippingAmountLocaleFull ?? ""))
                                    .font(.system(size: 14, weight: .regular))                        }
                                
                                HStack{
                                    Text("Taxes")
                                        .font(.system(size: 14, weight: .regular))
                                    Spacer()
                                    Text("₹" + (viewModel.sessionData?.paymentDetails.order?.taxAmountLocaleFull ?? ""))
                                    .font(.system(size: 14, weight: .regular))                        }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total")
                                        .font(.system(size: 14, weight: .bold))
                                    Spacer()
                                    Text("₹" + (viewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0"))
                                    .font(.system(size: 14, weight: .bold))                        }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                
                                
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                        }
                        
                        // Security Footer
                        HStack {
                            Spacer()
                            Text("Secured by")
                                .font(.system(size: 11, weight: .bold))
                            Image(frameworkAsset:"boxpay_logo") // Replace with your asset name
                                .resizable()
                                .frame(width: 50, height: 30)
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        Spacer()
                    }
                }.background(Color(UIColor.systemGray6).ignoresSafeArea())
            }.onAppear {
                viewModel.getCheckoutSession(token : token)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.processPaymentOptions()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    struct PaymentOption: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
        let subTitle: String
        
        // Dynamic property for all options
        static func allOptions(
            cardsMethod: Bool,
            walletMethods: Bool,
            netBankingMethods: Bool,
            emiMethod: Bool,
            bnplMethod: Bool
        ) -> [PaymentOption] {
            var options = [PaymentOption]()
            
            if cardsMethod {
                options.append(PaymentOption(imageName: "card_grey", title: "Cards", subTitle: "Save and pay via cards"))
            }
            if walletMethods {
                options.append(PaymentOption(imageName: "wallet_grey", title: "Wallet", subTitle: "Paytm, GooglePay, PhonePe & more"))
            }
            if netBankingMethods {
                options.append(PaymentOption(imageName: "bank_grey", title: "Netbanking", subTitle: "Select from a list of banks"))
            }
            if emiMethod {
                options.append(PaymentOption(imageName: "emi_grey", title: "EMI", subTitle: "Easy Installments"))
            }
            if bnplMethod {
                options.append(PaymentOption(imageName: "bnpl_grey", title: "Pay Later", subTitle: "Save and pay via cards"))
            }
            
            return options
        }
    }
    
    
    class CheckoutViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var sessionData: CheckoutSession? {
            didSet {
                if let paymentOptions = sessionData?.configs.paymentMethods, !paymentOptions.isEmpty {
                    print("Payment options loaded: \(paymentOptions)")
                }
            }
        }
        @Published var errorMessage: String = "Something Went Wrong"
        
        var paymentOptionList: [PaymentMethod] {
            sessionData?.configs.paymentMethods ?? []
        }
        
        func getCheckoutSession(token: String) {
            isLoading = true
            let apiService = APIServiceSessionApi()
            
            apiService.getCheckoutSession(token: token) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let data):
                        self?.sessionData = data
                        print("API Response: \(data)")
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("API Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    
    
    struct MainSheetPreview: PreviewProvider {
        static var previews: some View {
            MainCheckoutSheet(token: "")
        }
    }
    
    class APIServiceSessionApi {
        
        func getCheckoutSession(token: String, completion: @escaping (Result<CheckoutSession, Error>) -> Void) {
            let baseUrl = "https://test-apis.boxpay.tech/v0/checkout/sessions/"
            guard let url = URL(string: baseUrl + token) else {
                print("Invalid URL")
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                    return
                }
                
                do {
                    let checkoutSession = try JSONDecoder().decode(CheckoutSession.self, from: data)
                    completion(.success(checkoutSession))
                } catch {
                    // Print the error for debugging
                    print("Decoding error: \(error)")
                    // Optionally, print the raw JSON for verification
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON: \(jsonString)")
                    }
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func decodeCheckoutSession(data: Data, completion: @escaping (Result<CheckoutSession, Error>) -> Void) {
        // Try to parse the JSON first
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // Convert the dictionary back into `Data` for decoding
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                
                // Decode the `jsonData` into `CheckoutSession`
                let checkoutSession = try decoder.decode(CheckoutSession.self, from: jsonData)
                
                // Pass the result back in the completion handler
                completion(.success(checkoutSession))
            } catch {
                // Handle any errors during decoding
                completion(.failure(error))
            }
        } else {
            // Handle error if JSON is not valid
            completion(.failure(NSError(domain: "Invalid JSON", code: -3, userInfo: nil)))
        }
    }
    
    struct OrderItemView: View {
        let item: OrderItem
        
        var body: some View {
            HStack(spacing: 12) { // Adjust spacing for a clean look
                // Load the image
                if #available(iOS 15.0, *) {
                    AsyncImage(url: URL(string: item.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(8) // Add padding inside the square
                            .frame(width: 50, height: 50) // Ensure image size fits
                            .background(Color.white) // Background color for padding area
                            .cornerRadius(10) // Rounded corners
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                } else {
                    // Fallback on earlier versions
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.itemName)
                        .font(.system(size: 14, weight: .regular))
                        .lineLimit(2) // Truncate long names
                        .foregroundColor(.black)
                    
                    Text("Qty: \(item.quantity)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Price
                Text("₹\(String(format: "%.2f", item.amountWithoutTax + (item.taxAmount)))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(Color.white)
        }
    }
    
    
    struct ItemsListView: View {
        let items: [OrderItem]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 10) { // Adjust spacing between items
                    ForEach(items) { item in
                        OrderItemView(item: item)
                            .background(Color.white)
                    }
                }
                .padding(.horizontal, 0) // Add slight horizontal padding for the entire list
            }
            .background(Color(UIColor.white)) // Light background color
        }
    }
    
}
