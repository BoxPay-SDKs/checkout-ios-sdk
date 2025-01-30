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

    var body: some View {
        NavigationView {
            VStack {
                Text("Boxpay Testing")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    viewModel.generateToken { success in
                        if success {
                            navigateToCheckout = true // Navigate on success
                        }
                    }
                }) {
                    Text("Proceed to Checkout")
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
                NavigationLink(
                    destination: MainCheckoutSheet(
                        token: viewModel.token ?? "",
                        baseUrlFlag: 0,
                        onPaymentResult: { result in
                            print("Payment Result aagya baabe: \(result.status)")
                            // Handle result here (e.g., update UI, notify server, etc.)
                        }
                    ),
                    isActive: $navigateToCheckout
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
        request.addValue("Bearer tVTBfIiwpdR5gUlUQ9cDGfO9NceZ4p4QUIclTQnPWcVvZlLyOOEPJ3nF18UKvvpfAcNCSgr4VDzQiAkTXhhBbs", forHTTPHeaderField: "Authorization")
        request.addValue("Android SDK", forHTTPHeaderField: "X-Client-Connector-Name")
        request.addValue("1.0.0", forHTTPHeaderField: "X-Client-Connector-Version")

        //token generation json
        let jsonData = """
        {
          "context" : {
            "countryCode" : "IN",
            "legalEntity" : {
              "code" : "easebuzz"
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
                        "address1": "first line",
                        "address2": "second line",
                        "address3": null,
                        "city": "Chandigarh",
                        "state": "Chandigarh",
                        "countryCode": "IN",
                        "postalCode": "160002",
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
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let token = json["token"] as? String else {
                    self.errorMessage = "Failed to parse response."
                    completion(false)
                    return
                }

                self.token = token
                print("Token: \(token)")
                completion(true)
            }
        }.resume()
    }
}

