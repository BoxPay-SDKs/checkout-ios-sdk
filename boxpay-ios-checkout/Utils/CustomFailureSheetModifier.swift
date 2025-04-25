////
////  CustomFailureSheetModifier.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 29/01/25.
////
//
//import SwiftUI
//
//// Step 1: Create a custom ViewModifier for the sheet
//struct CustomFailureSheetModifier: ViewModifier {
//    var showSheet: Binding<Bool>
//    var onRetryPayment: () -> Void
//    var onReturnToPaymentOptions: () -> Void
//    var sheetHeight: CGFloat
//    var isInteractiveDismissDisabled: Bool
//
//    func body(content: Content) -> some View {
//        content
//            .sheet(isPresented: showSheet) {
//                if #available(iOS 16.0, *) {
//                    PaymentFailureScreen(
//                        transactionID: "", reasonCode: "", reason: "",
//                        onRetryPayment: {
//                            onRetryPayment() // Trigger custom retry payment action
//                        },
//                        onReturnToPaymentOptions: {
//                            onReturnToPaymentOptions() // Trigger custom return to payment action
//                        }
//                    )
//                    .presentationDetents([.height(sheetHeight)])
//                    .presentationDragIndicator(.visible)
//                    .interactiveDismissDisabled(isInteractiveDismissDisabled)
//                } else {
//                    // Fallback for iOS versions below 16
//                    Text("Payment Failure Screen - Fallback for iOS < 16")
//                }
//            }
//    }
//}
//
//// Step 2: Create an extension to apply the modifier easily
//extension View {
//    func customFailureSheet(
//        showSheet: Binding<Bool>,
//        onRetryPayment: @escaping () -> Void,
//        onReturnToPaymentOptions: @escaping () -> Void,
//        sheetHeight: CGFloat = 400,
//        isInteractiveDismissDisabled: Bool = true
//    ) -> some View {
//        self.modifier(
//            CustomFailureSheetModifier(
//                showSheet: showSheet,
//                onRetryPayment: onRetryPayment,
//                onReturnToPaymentOptions: onReturnToPaymentOptions,
//                sheetHeight: sheetHeight,
//                isInteractiveDismissDisabled: isInteractiveDismissDisabled
//            )
//        )
//    }
//}
