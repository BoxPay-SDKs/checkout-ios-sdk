////
////  RepeatingTask.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 29/01/25.
////
//
//import SwiftUI
//import Foundation
//import UIKit
//import Combine
//
//class RepeatingTask: ObservableObject {
//    private var timer: Timer?
//    var paymentViewModel = PaymentViewModel()
////    let apiManager = APIManager()
//    @Published var callFetchStatus = true  // Now published, so changes notify SwiftUI
//
//    func startRepeatingTask(showSuccesScreen: Binding<Bool>, showFailureScreen: Binding<Bool>, isLoading: Binding<Bool>) {
////        let baseURL = apiManager.getBaseURL()
////        let token = "v0/checkout/sessions/" + apiManager.getMainToken() + "/status"
////        
////        guard let url = URL(string: "\(baseURL)\(token)") else {
////            print("Invalid URL")
////            return
////        }
////        
////        callFetchStatus = true // Ensure flag is set to true when starting
////        
////        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
////            guard let self = self, self.callFetchStatus else {
////                print("Timer stopped, skipping API call")
////                return
////            }
////
////            self.paymentViewModel.fetchStatusAndReason(
////                url: url.absoluteString,
////                showSuccessScreen: showSuccesScreen,
////                showFailureScreen: showFailureScreen,
////                repeatingTask: self,
////                isLoading: isLoading
////            )
////        }
//    }
//    
//    func stopRepeatingTask() {
//        print("Stopping repeating task")
//        callFetchStatus = false // Prevents further execution
//        timer?.invalidate()
//        timer = nil
//    }
//}
//
//
