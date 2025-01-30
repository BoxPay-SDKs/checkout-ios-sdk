import SwiftUI

struct GeneralSuccessScreen: View {
    var transactionID: String
    var date: String
    var time: String
    var paymentMethod: String
    var totalAmount: String
    var onDone: (() -> Void)? = nil // Optional callback for "Done" button

    var body: some View {
        VStack(spacing: 20) {
            // Success Icon
            Image(frameworkAsset: "green_success")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            // Payment Success Text
            Text("Payment Successful!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.green)

            // Details Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Transaction ID")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(transactionID)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }

                HStack {
                    Text("Date")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(date)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }

                HStack {
                    Text("Time")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(time)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }

                HStack {
                    Text("Payment Method")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(paymentMethod)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)

            DottedDivider()

            // Total Amount Section
            HStack {
                Text("Total Amount")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text(totalAmount)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)

            DottedDivider()
            // Additional Info Text
            Text("You will be redirected to the merchant’s page")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            // Done Button
            Button(action: {
                onDone?() // Execute the callback when "Done" is pressed
            }) {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 5)
        }
        .padding(EdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16))
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct DottedDivider: View {
    var padding: CGFloat = 20 // Set padding value
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width - 2 * padding // Adjust width by removing padding from both sides
                let height: CGFloat = 1
                let spacing: CGFloat = 5 // Space between dots
                let dashLength: CGFloat = 4 // Length of each dot

                var x: CGFloat = padding // Start from the padding
                
                while x < width + padding {
                    path.move(to: CGPoint(x: x, y: height / 2))
                    path.addLine(to: CGPoint(x: x + dashLength, y: height / 2))
                    x += dashLength + spacing
                }
            }
            .stroke(Color.gray.opacity(0.6), lineWidth: 1) // Softer color
        }
        .frame(height: 1) // Controls the height of the line
    }
}

struct GeneralSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSuccessScreen(
            transactionID: "000085752257",
            date: "Mar 28, 2024",
            time: "07:30 AM",
            paymentMethod: "Credit Card(EMI)",
            totalAmount: "₹2,590"
        )
    }
}
