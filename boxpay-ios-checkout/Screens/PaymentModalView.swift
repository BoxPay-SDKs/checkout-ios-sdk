import SwiftUI

struct PaymentModalView: View {
    let price: Double
    @State private var selectedPaymentMethod: String? = "Paytm UPI"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Payment Header
            HStack {
                Text("Payment ₹\(String(format: "%.2f", price))")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: {
                    // Handle other options action
                }) {
                    Text("Other Options >")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.green)
                }
            }
            
            // Last Used Payment Option Label
            Text("Last Used Payment Option")
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            // Payment Option
            HStack {
                Image("paytm_logo") // Add Paytm logo asset
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(4)
                
                Text("Paytm UPI")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // Radio Button
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            // Proceed to Pay Button
            Button(action: {
                print("Proceeding to pay ₹\(String(format: "%.2f", price))")
                // Handle payment action here
            }) {
                Text("Proceed to Pay ₹\(String(format: "%.2f", price))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding()
    }
}

struct PaymentModalView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentModalView(price: 36770)
    }
}
