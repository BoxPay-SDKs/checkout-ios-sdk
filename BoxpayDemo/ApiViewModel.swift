//
//  ApiViewModel.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 21/04/25.
//

import Foundation

class APIViewModel: ObservableObject {
    @Published var token: String?
    @Published var shopperToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    //replace baseUrl for token generation
    private lazy var url = "https://test-apis.boxpay.tech/v0/merchants/lGfqzNSKKA/sessions"
    
    
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
        request.addValue("Bearer 3z3G6PT8vDhxQCKRQzmRsujsO5xtsQAYLUR3zcKrPwVrphfAqfyS20bvvCg2X95APJsT5UeeS5YdD41aHbz6mg", forHTTPHeaderField: "Authorization")
        request.addValue("IOS SDK", forHTTPHeaderField: "X-Client-Connector-Name")
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
            "amount" : "15000",
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
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let token = json["token"] as? String {
                            self.token = token
                            if let payload = json["payload"] as? [String: Any],
                               let shopperToken = payload["shopper_token"] as? String {
                                self.shopperToken = shopperToken
                                print("✅ Shopper Token: \(shopperToken)")
                            }
                            print("✅ Token: \(token)")
                            completion(true)
                        } else {
                            self.errorMessage = "Failed to parse response."
                            completion(false)
                        }
                    } catch {
                        self.errorMessage = "JSON Parsing Error: \(error.localizedDescription)"
                        completion(false)
                    }
                } else {
                    self.errorMessage = "No data received from server."
                    completion(false)
                }
            }
        }.resume()
        
    }
}
