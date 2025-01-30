//
//  TimeDifferenceCalculator.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 23/01/25.
//

import Foundation

class TimeDifferenceCalculator {
    private let dateFormatter: DateFormatter

    init() {
        // Initialize the DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss zzz"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
    }

    func calculateDifferenceInSeconds(from apiTime: String) -> Int? {
        // Parse the API time string into a Date object
        guard let apiDate = dateFormatter.date(from: apiTime) else {
            print("Error: Unable to parse API time")
            return nil
        }

        // Get the current system time
        let currentDate = Date()

        // Calculate the difference in seconds
        let differenceInSeconds = Int(currentDate.timeIntervalSince(apiDate))

        return differenceInSeconds
    }
}
