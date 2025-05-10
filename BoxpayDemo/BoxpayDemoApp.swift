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
    @StateObject private var viewModel = APIViewModel()
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
    @State private var inputShopperToken: String = ""
    @State private var baseUrlFlag: Int = 0
    @State private var selectedOption: String = "Test" // Default selected item
    let options = ["Test", "Production"] // Spinner items
    @State private var navigateToCheckoutUsingCustomToken = false
    @State private var selectedToken: String? // For passing token to destination
    @State private var selectedShopperToken: String? // For passing token to destination
    @State private var status:String = ""
    @State private var transactionId : String = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Boxpay  Testing")
                    .font(.largeTitle)
                    .padding()
                
                if hidden {
                    TextField("Enter custom Token", text: $inputToken)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    TextField("Enter shopper Token", text: $inputShopperToken)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
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
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: selectedOption) { newValue in
                        switch newValue {
                        case "Test":
                            baseUrlFlag = 0
                        case "Production":
                            baseUrlFlag = 1
                        default:
                            break
                        }
                    }
                    
                    Button(action: {
                        if !inputToken.isEmpty {
                            selectedToken = inputToken
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
                
                // ✅ Use Default Token Button
                Button(action: {
                    viewModel.generateToken { success in
                        if success, let token = viewModel.token {
                            selectedToken = token
                            if let shopperToken = viewModel.shopperToken {
                                selectedShopperToken = shopperToken
                            }
                            navigateToCheckout = true
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
                
                // ✅ Hidden NavigationLinks (Trigger based on state)
                NavigationLink(
                    destination: Group {
                        if let token = selectedToken {
                            BoxpayCheckout(
                                token: token,
                                shopperToken: selectedShopperToken ?? "",
                                configurationOptions: [
                                    ConfigurationOption.enableTextEnv : true,
                                    ConfigurationOption.showBoxpaySuccessScreen : true
                                ],
                                onPaymentResult: { result in
                                    status = result.status
                                    transactionId = result.transactionId
                                    showAlert = true
                                }
                            )
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $navigateToCheckout
                ) {
                    EmptyView()
                }

                
                NavigationLink(
                    destination: Group {
                        if let token = selectedToken {
                            BoxpayCheckout(
                                token: token,
                                shopperToken: inputShopperToken,
                                configurationOptions: [
                                    ConfigurationOption.enableTextEnv : true,
                                    ConfigurationOption.showBoxpaySuccessScreen : true
                                ],
                                onPaymentResult: { result in
                                    status = result.status
                                    transactionId = result.transactionId
                                    showAlert = true
                                }
                            )
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $navigateToCheckoutUsingCustomToken
                ) {
                    EmptyView()
                }

            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .background(Color.white)
            .preferredColorScheme(.light)
            .navigationBarBackButtonHidden(true)
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Payment Result"),
                message: Text("Status \(status) & transactionId \(transactionId)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
