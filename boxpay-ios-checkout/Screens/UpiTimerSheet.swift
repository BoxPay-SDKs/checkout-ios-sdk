//
//  UpiTimerSheet.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 04/02/25.
//

import SwiftUI

struct UpiTimerSheet: View {
    var onCancelButton: () -> Void
    @Binding var timeRemaining: Int // Timer state passed from parent
    @Binding var progress: CGFloat // Progress state passed from parent
    @Environment(\.presentationMode) var presentationMode // To dismiss the screen
    @Binding var vpa: String // Use @Binding instead of @State

    // Timer setup
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Custom initializer to pass vpa, timeRemaining, and progress
    init(vpa: Binding<String>, timeRemaining: Binding<Int>, progress: Binding<CGFloat>, onCancelButton: @escaping () -> Void) {
        self._vpa = vpa
        self._timeRemaining = timeRemaining
        self._progress = progress
        self.onCancelButton = onCancelButton
    }

    var body: some View {
        VStack(spacing: 16) {
            // Close Button
            HStack(spacing: 2) {
                Button(action: {
                    onCancelButton()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }

                // Title
                Text("Complete your Payment")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()
            }
            .padding(.top, 30)

            // Instruction
            Text("Open your UPI application and confirm the payment before the time expires")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            // UPI ID
            HStack(spacing: 5) {
                Image(frameworkAsset: "upi_icon_grey")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)

                Text("UPI Id : " + vpa)
                    .font(.system(size: 14))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray, lineWidth: 1))

            // Timer Label
            Text("Expires in")
                .font(.system(size: 17, weight: .semibold))

            // Circular Countdown Timer
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8) // Background Circle

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text("\(formattedTime())")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
            }
            .frame(width: 120, height: 120)

            // Note
            Text("Note: Kindly avoid using the back button until the transaction process is complete")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Divider()

            // Cancel Payment Button
            Button(action: {
                onCancelButton()
            }) {
                Text("Cancel Payment")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
            }
            .padding(.bottom, 1)

            Divider()
        }
        .padding()
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = CGFloat(timeRemaining) / 300.0
            } else if timeRemaining == 0 {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // Format time to MM:SS
    private func formattedTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct PaymentProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        UpiTimerSheet(
            vpa: .constant("test-initiated@boxpay"), // Mock UPI ID
            timeRemaining: .constant(300), // Mock initial time remaining (5 minutes)
            progress: .constant(1.0), // Mock initial progress (100%)
            onCancelButton: {} // Mock cancel button action
        )
    }
}
