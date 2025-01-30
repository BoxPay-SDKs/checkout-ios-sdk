//
//  RepeatingTask.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 29/01/25.
//

import SwiftUI
import Foundation
import UIKit
import Combine

class RepeatingTask {
    var timer: Timer?
    var paymentViewModel = PaymentViewModel() // Initialize as a @StateObject only in SwiftUI Views
    let apiManager = APIManager()
    var callFetchStatus = true
    
    func startRepeatingTask(showSuccesScreen: Binding<Bool>, showFailureScreen: Binding<Bool>, repeatingTask: RepeatingTask, isLoading: Binding<Bool>) {
        let baseURL = apiManager.getBaseURL()
        let token = "v0/checkout/sessions/" + apiManager.getMainToken() + "/status"
        
        guard let url = URL(string: "\(baseURL)\(token)") else {
            print("Invalid URL")
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if(self.callFetchStatus){
                self.paymentViewModel.fetchStatusAndReason(url: url.absoluteString, showSuccessScreen: showSuccesScreen,showFailureScreen: showFailureScreen, repeatingTask: repeatingTask, isLoading: isLoading)
            }
        }
    }
    
    func stopRepeatingTask() {
        print("Repeating task stopped")
        self.callFetchStatus = false
        timer?.invalidate() // Stop the timer
        timer = nil
    }
}
