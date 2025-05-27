//
//  StringUtils.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/05/25.
//

import Foundation

struct StringUtils {
    static func generateRandomAlphanumericString(length: Int) -> String {
        let charPool = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""

        for _ in 0..<length {
            if let randomChar = charPool.randomElement() {
                result.append(randomChar)
            }
        }

        return result
    }
    
    static func formatDate(from input: String, to outputFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata") // Set IST manually
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let cleanedInput = input.replacingOccurrences(of: " IST", with: "")
        
        if let date = formatter.date(from: cleanedInput) {
            formatter.dateFormat = outputFormat
            return formatter.string(from: date)
        } else {
            return "-"
        }
    }
    
    static func getRequestHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "X-REQUEST-ID": StringUtils.generateRandomAlphanumericString(length: 10),
            "X-Client-Connector-Name":"IOS SDK",
            "X-Client-Connector-Version":SDKVersion.version
        ]
    }
}

extension String {
    func chunked(into size: Int) -> [String] {
        var result: [String] = []
        var currentIndex = startIndex
        
        while currentIndex < endIndex {
            let nextIndex = index(currentIndex, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(String(self[currentIndex..<nextIndex]))
            currentIndex = nextIndex
        }
        
        return result
    }
}
