//
//  EMIDetailsView.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 13/02/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct EMIDetailsView: View {
    let emiOptions: [PaymentMethod]
    @State private var selectedEmiId: String?
    @State private var selectedDuration: Int?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var checkOutViewModel = CheckoutViewModel()
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    @State private var selectedEMI: PaymentMethod? // Store selected EMI
    @State private var navigateToAddCard = false   // Track navigation
    
    private var currencySymbol: String{
        checkOutViewModel.sessionData?.paymentDetails.money.currencySymbol ?? "₹"
        }
    
    var body: some View {
        NavigationView {
            VStack {
                PaymentHeaderView(
                    title: "Select Tenure",
                    itemCount: checkOutViewModel.sessionData?.paymentDetails.order?.items?.count ?? 0,
                    totalPrice: checkOutViewModel.sessionData?.paymentDetails.money.amountLocaleFull ?? "0",
                    currencySymbol: currencySymbol,
                    onBack: { presentationMode.wrappedValue.dismiss() }
                )
                
                Spacer()
                
                ZStack {
                    Color(.systemGray6).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            headerView // EMI header
                            emiListView
                            
                        }.background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                        
                        FooterView()
                            .padding(.top, 10)
                    }
                    .hideKeyboardOnTap()
                }
            }
            .onAppear {
                let apiManager = APIManager()
                checkOutViewModel.getCheckoutSession(token: apiManager.getMainToken())
                isLoading = false
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .preferredColorScheme(.light)
        }.navigate(to: AddCardView(emi: selectedEMI), when: $navigateToAddCard)
    }
    
    private var headerView: some View {
        HStack {
            bankImageView(bank: emiOptions.first!)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .padding(.leading, 2)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text("\(emiOptions.first?.emiMethod?.issuerTitle ?? "Unknown Bank") | \(emiOptions.first?.title ?? "")")
                .font(.headline)
        }.padding(.bottom,7)
            .padding(.leading,10)
            .padding(.trailing,10)
            .padding(.top,15)
    }
    
    private var emiListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(emiOptions, id: \.compositeID) { emi in
                VStack(alignment: .leading, spacing: 1) {
                    if emi == emiOptions.first {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                    
                    emiRow(emi: emi)
                    
                    if emi != emiOptions.last {
                        Divider().background(Color.gray.opacity(0.3))
                    }
                }
                .background((selectedEmiId == emi.id && selectedDuration == emi.emiMethod?.duration) ? Color(hex: "#FAFAFA") : Color.clear)
            }
        }
        .background(Color.white)
        .cornerRadius(1)
        .padding(.top, 10)
    }
    
    private func emiRow(emi: PaymentMethod) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // EMI Selection Row (Always Visible)
            Button(action: {
                selectedEmiId = emi.id
                selectedDuration = emi.emiMethod?.duration
            }) {
                HStack {
                    Image(systemName: (selectedEmiId == emi.id && selectedDuration == emi.emiMethod?.duration) ? "largecircle.fill.circle" : "circle")
                        .foregroundColor((selectedEmiId == emi.id && selectedDuration == emi.emiMethod?.duration) ? .green : .gray)
                        .font(.system(size: 18))
                        .padding(.leading, 15)

                    VStack(alignment: .leading) {
                        Text("\(emi.emiMethod?.duration ?? 0) months x \(currencySymbol)\(emi.emiMethod?.emiAmount ?? 0, specifier: "%.0f")")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 5)

                    if !emi.tags.isEmpty {
                        HStack {
                            ForEach(emi.tags, id: \.self) { tag in
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

                    Spacer()
                }
                .frame(height: 44)
                .padding(.vertical, 10) // ✅ Ensures a good tap area
                .contentShape(Rectangle()) // ✅ Makes the entire row tappable
            }
            .buttonStyle(PlainButtonStyle()) // Removes default button animation

            // Additional EMI Details (Only Visible When Selected)
            if selectedEmiId == emi.id && selectedDuration == emi.emiMethod?.duration {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Monthly EMI")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.leading, 5)

                        Text("Interest @\(emi.emiMethod?.interestRate ?? 0, specifier: "%.1f")% p.a.")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("Discount")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("Total Cost")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.trailing, 5)
                    }
                    .padding(.vertical, 10)
                    .background(Color(hex: "#F1F1F1"))

                    Divider()

                    HStack {
                        Text("\(currencySymbol)\(emi.emiMethod?.emiAmount ?? 0, specifier: "%.2f")")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.leading, 5)

                        Text("\(currencySymbol)\(emi.emiMethod?.interestChargedAmount ?? 0, specifier: "%.2f")")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("-\(currencySymbol)\(emi.emiMethod?.merchantBorneInterestAmount ?? 0, specifier: "%.2f")")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("\(currencySymbol)\(emi.emiMethod?.totalAmount ?? 0, specifier: "%.2f")")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.trailing, 5)
                    }
                    .padding(.vertical, 10)
                    .background(Color.white)
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 15)

                VStack(alignment: .leading, spacing: 5) {
                    Text("**Note:** The bank will continue to charge interest on No Cost EMI plans as per existing rates. However, the interest to be charged by the bank will be passed on to you as an upfront discount.")
                        .font(.system(size: 12))
                        .padding(.horizontal, 15)
                        .padding(.top, 10)

                    if let cashback = emi.emiMethod?.merchantPayback, let cashbackAmount = Double(cashback), cashbackAmount > 0 {
                        Text("\(currencySymbol)\(cashbackAmount, specifier: "%.1f") Cashback will be processed after successful payment")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                    }

                    if let processingFee = emi.emiMethod?.processingFee?.amount {
                        Text("**\(currencySymbol)\(processingFee, specifier: "%.0f")+GST** will be charged by \(emi.emiMethod?.issuerTitle ?? "the bank") as one-time processing fee.")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                    }
                }

                proceedToPayButton(emi: emi)
                    .padding(.top, 5)
                    .padding(.bottom, 10)
            }
        }
        .background((selectedEmiId == emi.id && selectedDuration == emi.emiMethod?.duration) ? Color(hex: "#FAFAFA") : Color.clear)
    }

    
    
    
    private func proceedToPayButton(emi: PaymentMethod) -> some View {
        Button(action: {
            selectedEMI = emi  // ✅ Store selected EMI
            navigateToAddCard = true  // ✅ Trigger navigation
            print("Proceed to pay using EMI from \(emi.emiMethod?.issuerTitle ?? "")")
        }) {
            Text("Proceed to Enter Card Details")
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

extension PaymentMethod {
    var compositeID: String {
        let emiDuration = emiMethod?.duration ?? 0
        let emiAmount = emiMethod?.emiAmount ?? 0.0
        return "\(id ?? UUID().uuidString)-\(emiDuration)-\(emiAmount)"
    }
}



struct EMIDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            let sampleEMIOption = PaymentMethod(
                id: "a6d0bd14-e6f1-3281-9c72-b65d6917b723",
                type: "Emi",
                brand: "CreditCardEMI",
                title: "Credit Card EMI",
                typeTitle: "EMI",
                logoUrl: "https://sandbox-images.boxpay.tech/v0/platform/public/orgs/boxpay/files/paymentMethod-AmericanExpress-m.svg",
                instrumentTypeValue: "emi/cc",
                applicableOffers: [],
                emiMethod: EmiMethod(
                    brand: "CreditCardEMI",
                    issuer: "AmericanExpress",
                    duration: 12,
                    interestRate: 14,
                    minAmount: 5000,
                    merchantPayback: "7.19",
                    subvention: "Customer",
                    processingFee: ProcessingFee(
                        feeType: "Fixed",
                        percentage: 0.00,
                        amount: 199,
                        amountLocale: "199",
                        amountLocaleFull: "199"
                    ),
                    emiAmount: 2244.68,
                    totalAmount: 26936.16, 
                    interestChargedAmount: 1936.16,
                    bankChargedInterestAmount: 1936.16,
                    merchantBorneInterestAmount: 0,
                    logoUrl: "https://sandbox-images.boxpay.tech/v0/platform/public/orgs/boxpay/files/paymentMethod-AmericanExpress-m.svg",
                    netAmount: 25000,
                    merchantBorneInterestRate: 0,
                    issuerTitle: "American Express",
                    effectiveInterestRate: 14,
                    minAmountLocale: "5,000",
                    minAmountLocaleFull: "5,000",
                    emiAmountLocale: "2,244.68",
                    emiAmountLocaleFull: "2,244.68",
                    totalAmountLocale: "26.94 K",
                    totalAmountLocaleFull: "26,936.16",
                    interestChargedAmountLocale: "1,936.16",
                    interestChargedAmountLocaleFull: "1,936.16",
                    bankChargedInterestAmountLocale: "1,936.16",
                    bankChargedInterestAmountLocaleFull: "1,936.16",
                    merchantBorneInterestAmountLocale: "0",
                    merchantBorneInterestAmountLocaleFull: "0",
                    netAmountLocale: "25 K",
                    netAmountLocaleFull: "25,000",
                    cardlessEmiProvider: nil,
                    cardlessEmiProviderTitle: nil,
                    cardlessEmiProviderValue: nil
                )
            )
            
            @State var selectedEMIOptions: [PaymentMethod] = [sampleEMIOption]
            EMIDetailsView(emiOptions: selectedEMIOptions)
        }
    }
}


