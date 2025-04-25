////
////  PaymentViewModel.swift
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
//
//class PaymentViewModel: ObservableObject {
//    @Published var transactionId: String = ""
//    @Published var status: String = ""
//    @Published var statusReason: String = ""
//    @Published var reasonCode: String = ""
//    @Published var currencySymbol: String = ""
//    
//    // New properties for success screen
//    @Published var transactionDate: String = "" // Store the transaction date
//    @Published var transactionTime: String = "" // Store the transaction time
//    @Published var paymentMethod: String = "" // Store the payment method
//    @Published var totalAmount: String = "" // Store the total amount
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func fetchStatusAndReason(url: String, showSuccessScreen: Binding<Bool> , showFailureScreen : Binding<Bool>, repeatingTask: RepeatingTask, isLoading: Binding<Bool>) {
//        guard let requestUrl = URL(string: url) else { return }
//        
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = "GET"
//        request.addValue(generateRandomAlphanumericString(length: 10), forHTTPHeaderField: "X-Trace-Id")
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { output -> Data in
//                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
//                    throw URLError(.badServerResponse)
//                }
//                return output.data
//            }
//            .decode(type: PaymentResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                if case .failure(let error) = completion {
//                    self.handleError(error)
//                }
//            }, receiveValue: { [weak self] response in
//                self?.handleResponse(response: response, showSuccessScreen: showSuccessScreen,showFailureScreen: showFailureScreen, repeatingTask: repeatingTask, isLoading: isLoading)
//            })
//            .store(in: &cancellables)
//    }
//    
//    private func handleResponse(response: PaymentResponse, showSuccessScreen: Binding<Bool>, showFailureScreen : Binding<Bool>, repeatingTask: RepeatingTask, isLoading: Binding<Bool>) {
//        transactionId = response.transactionId ?? ""
//        status = response.status ?? ""
//        statusReason = response.statusReason ?? ""
//        reasonCode = response.reasonCode ?? ""
//        currencySymbol = response.currencySymbol ?? ""
//        // Populate additional details for success screen
//        transactionDate = formatDate(response.transactionTimestampLocale ?? "") // You can customize this method for your date format
//        transactionTime = formatTime(response.transactionTimestampLocale ?? "") // You can customize this method for your time format
//        paymentMethod = response.paymentMethod?.brand ?? "Unknown"
//        totalAmount = formatAmount(Double(response.amount ?? 0))
//        
//        switch response.status?.lowercased() {
//        case "pending":
//            print("Pending Transaction")
//            break
//        case "rejected", "failed":
//            print("rejected Transaction")
//            isLoading.wrappedValue = false
//            showSuccessScreen.wrappedValue = false
//            showFailureScreen.wrappedValue = true
//            repeatingTask.stopRepeatingTask()
//            break
//        case "requiresaction":
//            print("requiresaction Transaction")
//            break
//        case "approved", "paid":
//            print("approved Transaction")
//            isLoading.wrappedValue = false
//            showFailureScreen.wrappedValue = false
//            showSuccessScreen.wrappedValue = true
//            repeatingTask.stopRepeatingTask()
//            break
//        default:
//            print("Unknown Transaction")
//            break
//        }
//    }
//    
//    private func handleError(_ error: Error) {
//        // Handle error case
//        print("Error: \(error.localizedDescription)")
//    }
//    
//    private func generateRandomAlphanumericString(length: Int) -> String {
//        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        return String((0..<length).map { _ in letters.randomElement()! })
//    }
//    
//    // Helper functions for formatting
//    func formatDate(_ timestamp: String) -> String {
//        let dateFormatter = DateFormatter()
//        
//        // Step 1: Set the input date format
//        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss z"
//        
//        // Step 2: Convert the string to a Date object
//        if let date = dateFormatter.date(from: timestamp) {
//            // Step 3: Set the desired output format (e.g., "Jan 22, 2025")
//            dateFormatter.dateFormat = "MMM dd, yyyy"
//            
//            // Step 4: Return the formatted date as a string
//            return dateFormatter.string(from: date)
//        }
//        return "Invalid Date"
//    }
//    
//    // Function to format the time (e.g., "02:45 PM")
//    func formatTime(_ timestamp: String) -> String {
//        let dateFormatter = DateFormatter()
//        
//        // Step 1: Set the input date format
//        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss z"
//        
//        // Step 2: Convert the string to a Date object
//        if let date = dateFormatter.date(from: timestamp) {
//            // Step 3: Set the desired output format (e.g., "02:45 PM")
//            dateFormatter.dateFormat = "hh:mm a"
//            // Step 4: Return the formatted time as a string
//            return dateFormatter.string(from: date)
//        }
//        return "Invalid Time"
//    }
//    
//    private func formatAmount(_ amount: Double) -> String {
//        // Convert the amount to a formatted string (e.g., ₹2,590)
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencySymbol = ""
//        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
//            return formattedAmount
//        }
//        return "0.00"
//    }
//}
