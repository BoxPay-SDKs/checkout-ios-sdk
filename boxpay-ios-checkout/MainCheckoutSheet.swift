import SwiftUI

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
    public init() {}
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
                        Text("2 Items · Total:")
                            .font(.system(size: 12, weight: .regular))
                        Text("₹36,770")
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
                            ForEach(PaymentOption.allOptions.indices, id: \.self) { index in
                                VStack(spacing: 0) {
                                    HStack(alignment: .center) { // Center-align content within each row
                                        // Load custom images from Media.xcassets
                                        Image(frameworkAsset: PaymentOption.allOptions[index].imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20) // Ensure consistent icon size
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(PaymentOption.allOptions[index].title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .lineLimit(1) // Ensure text doesn’t overflow
                                            
                                            Text(PaymentOption.allOptions[index].subTitle)
                                                .font(.system(size: 10, weight: .regular))
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .frame(width: 20, height: 20) // Ensure consistent chevron size
                                    }
                                    .padding(.vertical)
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    
                                    // Add divider only between rows, not after the last row
                                    if index < PaymentOption.allOptions.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .background(Color.white) // Big card background
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Order Summary")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Text("Price Details")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("₹36,770")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            HStack{
                                Text("Item Total(8 Items)")
                                    .font(.system(size: 14, weight: .regular))
                                
                                Spacer()
                                Text("₹36,765")
                                .font(.system(size: 14, weight: .regular))                        }
                            
                            HStack{
                                Text("Sub Total")
                                    .font(.system(size: 14, weight: .regular))
                                Spacer()
                                Text("₹36,765")
                                .font(.system(size: 14, weight: .regular))                        }
                            
                            HStack{
                                Text("Taxes")
                                    .font(.system(size: 14, weight: .regular))
                                Spacer()
                                Text("₹5")
                                .font(.system(size: 14, weight: .regular))                        }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text("₹36,770")
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
        }.navigationBarBackButtonHidden(true)
    }
}

struct PaymentOption: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subTitle: String
    
    static let allOptions = [
        PaymentOption(imageName: "card_grey", title: "Cards", subTitle: "Save and pay via cards"),
        PaymentOption(imageName: "wallet_grey", title: "Wallet", subTitle: "Paytm, GooglePay, PhonePe & more"),
        PaymentOption(imageName: "bank_grey", title: "Netbanking", subTitle: "Select from a list of banks"),
        PaymentOption(imageName: "emi_grey", title: "EMI", subTitle: "Easy Installments"),
        PaymentOption(imageName: "bnpl_grey", title: "Pay Later", subTitle: "Save and pay via cards")
    ]
}

struct MainSheetPreview: PreviewProvider {
    static var previews: some View {
        MainCheckoutSheet()
    }
}
