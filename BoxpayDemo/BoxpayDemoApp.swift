//
//  BoxpayDemoApp.swift
//  BoxpayDemo
//
//  Created by ankush on 02/01/25.
//

import SwiftUI
import boxpay_ios_checkout
@main
struct BoxpayDemoApp: App {
    @StateObject private var viewModel = APIViewModel() // API ViewModel shared across the app

    var body: some Scene {
        WindowGroup {
            ContentViewTest(viewModel: viewModel)
        }
    }
} 


struct ContentViewTest: View {
    @ObservedObject var viewModel: APIViewModel // Receive the shared view model
    @State private var navigateToCheckout = false // State to control navigation
    @State private var hidden = true
    @State private var inputToken: String = ""
    @State private var baseUrlFlag: Int = 0
    @State private var selectedOption: String = "Test" // Default selected item
    let options = ["Test", "Sandbox", "Production"] // Spinner items
    @State private var navigateToCheckoutUsingCustomToken = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Boxpay Testing")
                    .font(.largeTitle)
                    .padding()

                if(hidden){
                    TextField("Enter custom Token", text: $inputToken)
                                .padding() // Add padding inside the field
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1) // Gray border
                                )
                                .background(Color.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                    
                    Picker("Select an option", selection: $selectedOption) {
                                    ForEach(options, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1) // Gray outline
                                )
                                .cornerRadius(8)
                                .padding(.horizontal) 
                                .onChange(of: selectedOption) { newValue in
                                    print("Selected item: \(newValue)")
                                    if(newValue == "Test"){
                                        baseUrlFlag = 0
                                    }else if(newValue == "Sandbox"){
                                        baseUrlFlag = 1
                                    }else if(newValue == "Production"){
                                        baseUrlFlag = 2
                                    }
                                }
                    
                    Button(action: {
                        if(!inputToken.isEmpty){
                            navigateToCheckoutUsingCustomToken = true
                        }
                    }) {
                        Text("Use custom token")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 250, height: 50)
                            .background(viewModel.isLoading ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 20)
                }
                

                Button(action: {
                    viewModel.generateToken { success in
                        if success {
                            navigateToCheckout = true // Navigate on success
                        }
                    }
                }) {
                    Text("Use Default Token")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250, height: 50)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.top, 20)

                // Display the result
                if viewModel.isLoading {
                    ProgressView("Generating Token...")
                        .padding()
                } else if let token = viewModel.token {
                    Text("Token: \(token)")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()

                // Hidden NavigationLink to trigger navigation programmatically
                //baseUrlFlag testing == 0, sandbox == 1, prod == 2
                if let token = viewModel.token, !token.isEmpty {
                    NavigationLink(
                        destination: MainCheckoutSheet(
                            token: token,
                            baseUrlFlag: baseUrlFlag,
                            onPaymentResult: { result in
                                print("Payment Result: \(result.status)")
                            }
                        ),
                        isActive: $navigateToCheckout
                    ) {
                        EmptyView()
                    }
                }
                
                //custom token naviagtion
                NavigationLink(
                    destination: MainCheckoutSheet(
                        token: inputToken,
                        baseUrlFlag: baseUrlFlag,
                        onPaymentResult: { result in
                            print("Payment Result aagya baabe 2: \(result.status)")
                            // Handle result here (e.g., update UI, notify server, etc.)
                        }
                    ),
                    isActive: $navigateToCheckoutUsingCustomToken
                ) {
                    EmptyView()
                }
            }
            .navigationBarTitle("Test App", displayMode: .inline)
            .background(Color(UIColor.white)).preferredColorScheme(.light)
                .navigationBarBackButtonHidden(true)
        }
    }
}


struct Previewer: PreviewProvider {
    static var previews: some View {
        ContentViewTest(viewModel: APIViewModel())
    }
}


class APIViewModel: ObservableObject {
    @Published var token: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var baseUrlProd: String = "https://apis.boxpay.in"
    @Published var baseUrlSandbox: String = "https://sandbox-apis.boxpay.tech"
    @Published var baseUrlTest: String = "https://test-apis.boxpay.tech"

    //replace baseUrl for token generation
    private lazy var url = baseUrlTest + "/v0/merchants/oh3mnorsME/sessions"


    func generateToken(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: self.url) else {
            self.errorMessage = "Invalid URL"
            completion(false)
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer i8zuZD3mR9SYvT29z3p4DHRigXBcL5Cu5H2Lpl5M9w1LP7BVqj79YE09vhrskbXTbJjtZ5HsLFfivNjtdCZZZk", forHTTPHeaderField: "Authorization")
        request.addValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")

        //token generation json
        let jsonData = """
        {
          "context" : {
            "countryCode" : "IN",
            "legalEntity" : {
              "code" : "razorpay"
            },
            "orderId" : "test12"
          },
          "paymentType" : "S",
          "money" : {
            "amount" : "25000",
            "currencyCode" : "INR"
          },
          "descriptor" : {
            "line1" : "Some descriptor"
          },
          "shopper": {
                    "firstName": "Ankush",
                    "lastName": "Kashyap",
                    "gender": null,
                    "phoneNumber": "917777777777",
                    "email": "ankush.kashyap@boxpay.tech",
                    "uniqueReference": "x123y",
                    "deliveryAddress": {
                        "address1": "#667",
                        "address2": "Sector-31",
                        "address3": null,
                        "city": "Chandigarh",
                        "state": "Chandigarh",
                        "countryCode": "IN",
                        "postalCode": "160030",
                        "shopperRef": null,
                        "addressRef": null,
                        "labelType": "Other",
                        "labelName": null,
                        "name": null,
                        "email": null,
                        "phoneNumber": null
                    },
                    "dateOfBirth": "2023-07-17T12:34:56Z",
                    "panNumber": "CTGPA2222D"
                },
          "order" : {
            "originalAmount" : 500,
            "shippingAmount" : 50,
            "voucherCode" : "VOUCHER",
            "taxAmount" :100,
            "totalAmountWithoutTax" : 550,
            "items" : [ {
              "id" : "test",
              "itemName" : "La Fille Regular Solid Handheld Bag Blue",
              "description" : "testProduct",
              "quantity" : 1,
              "manufacturer" : null,
              "brand" : null,
              "color" : null,
              "productUrl" : null,
              "imageUrl" : "https://assetscdn1.paytm.com/images/catalog/product/B/BA/BAGLAFILLE-BLUEINTO887307A255D05/1563381583133_0..jpg",
              "categories" : null,
              "amountWithoutTax" : 500,
              "taxAmount" : 76.27,
              "taxPercentage" : null,
              "discountedAmount" : null,
              "amountWithoutTaxLocale" : "10",
              "amountWithoutTaxLocaleFull" : "10"
            },{
              "id" : "test3",
              "itemName" : "La Fille Regular Solid Handheld Bag Blue",
              "description" : "testProduct",
              "quantity" : 1,
              "manufacturer" : null,
              "brand" : null,
              "color" : null,
              "productUrl" : null,
              "imageUrl" : "https://assetscdn1.paytm.com/images/catalog/product/B/BA/BAGLAFILLE-BLUEINTO887307A255D05/1563381583133_0..jpg",
              "categories" : null,
              "amountWithoutTax" : 500,
              "taxAmount" : 76.27,
              "taxPercentage" : null,
              "discountedAmount" : null,
              "amountWithoutTaxLocale" : "10",
              "amountWithoutTaxLocaleFull" : "10"
            },{
              "id" : "test4",
              "itemName" : "La Fille Regular Solid Handheld Bag Blue",
              "description" : "testProduct",
              "quantity" : 1,
              "manufacturer" : null,
              "brand" : null,
              "color" : null,
              "productUrl" : null,
              "imageUrl" : "https://assetscdn1.paytm.com/images/catalog/product/B/BA/BAGLAFILLE-BLUEINTO887307A255D05/1563381583133_0..jpg",
              "categories" : null,
              "amountWithoutTax" : 500,
              "taxAmount" : 76.27,
              "taxPercentage" : null,
              "discountedAmount" : null,
              "amountWithoutTaxLocale" : "10",
              "amountWithoutTaxLocaleFull" : "10"
            }]
          },
          "statusNotifyUrl" : "https://www.boxpay.tech",
          "frontendReturnUrl" : "https://www.boxpay.tech",
          "frontendBackUrl" : "https://www.boxpay.tech",
          "createShopperToken" : true,
          "expiryDurationSec" : 900
        }
        """.data(using: .utf8)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    if let urlError = error as? URLError {
                        print("❌ URL Error: \(urlError.localizedDescription)")
                        print("⏳ Failure Reason: \(String(describing: urlError.failureURLString))")
                        print("📡 Network Status: \(String(describing: urlError.networkUnavailableReason))")
                    } else {
                        print("❌ Request failed: \(error.localizedDescription)")
                    }
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response Code: \(httpResponse.statusCode)")
                    print("📜 Headers: \(httpResponse.allHeaderFields)")
                }

                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "❌ Unable to decode response"
                    print("📩 Response Data: \(responseString)")

                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let token = json["token"] as? String else {
                        self.errorMessage = "Failed to parse response."
                        completion(false)
                        return
                    }

                    self.token = token
                    print("✅ Token: \(token)")
                    completion(true)
                } else {
                    print("❌ No data received from server.")
                    self.errorMessage = "No data received from server."
                    completion(false)
                }
            }
        }.resume()

    }
}

