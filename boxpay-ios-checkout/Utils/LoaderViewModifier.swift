////
////  LoaderViewModifier.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 29/01/25.
////
//
//import SwiftUI
//
//// Step 1: Create a reusable ViewModifier for the loader
//struct LoaderOverlayModifier: ViewModifier {
//    var loaderText: String
//    
//    func body(content: Content) -> some View {
//        ZStack {
//            content // The original content of the view
//                .blur(radius: 3) // Optional: Apply blur to the background when the loader is active
//            
//            Color.black.opacity(0.5) // Background overlay
//                .ignoresSafeArea() // Cover the entire screen
//            
//            VStack { // Loader VStack
//                ProgressView() // Circular loader
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .scaleEffect(2) // Adjust loader size
//                
//                Text(loaderText) // Loading text
//                    .foregroundColor(.white)
//                    .font(.system(size: 16, weight: .medium))
//                    .padding(.top, 10)
//            }
//        }
//    }
//}
//
//// Step 2: Create an extension to make the modifier easier to apply
//extension View {
//    func showLoader(withText text: String) -> some View {
//        self.modifier(LoaderOverlayModifier(loaderText: text))
//    }
//}
