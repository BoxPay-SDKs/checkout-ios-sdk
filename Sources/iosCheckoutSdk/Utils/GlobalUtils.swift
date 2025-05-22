//
//  GlobalUtils.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import Foundation
import SwiftUI

struct GlobalUtils {
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
    
    @MainActor
    static func handle(
        timeStamp:String?,
        reasonCode: String?,
        reason: String?,
        methodType: String,
        response : PaymentActionResponse,
        shopperVpa:String
    ) async -> PaymentAction? {
        let checkoutManager = CheckoutManager.shared
        
        let status = await checkoutManager.getStatus()
        let paymentErrorMessage = await checkoutManager.getpaymentErrorMessage()
        
        switch status {
        case "REQUIRESACTION":
            if let actions = response.action, !actions.isEmpty, !methodType.isEmpty {
                let first = actions[0]
                switch methodType {
                case "UpiIntent":
                    let base64 = decodeBase64(url: first.url ?? "")
                    return .openIntentUrl(url: base64 ?? "")
                default:
                    if first.type == "html" {
                        return .openWebViewHTML(htmlString: first.htmlPageString ?? "")
                    } else {
                        return .openWebViewUrl(url: first.url ?? "")
                    }
                }
            } else if methodType == "UpiCollect" {
                return .openUpiTimer(shopperVpa: shopperVpa)
            }
            fallthrough  // if you want a default for empty actions
            
        case "FAILED", "REJECTED":
            let message: String
            if let code = reasonCode, !code.hasPrefix("UF") {
                message = paymentErrorMessage
            } else if let reason = reason, reason.contains(":") {
                message = reason
                    .split(separator: ":")
                    .dropFirst()
                    .joined(separator: ":")
                    .trimmingCharacters(in: .whitespaces)
            } else {
                message = reason ?? paymentErrorMessage
            }
            return .showFailed(message: message)
            
        case "APPROVED", "SUCCESS", "PAID":
            return .showSuccess(timestamp: timeStamp ?? "")
            
        case "EXPIRED":
            return .showExpired
            
        case "PENDING" where methodType == "UpiIntent":
            let message: String
            if let code = reasonCode, !code.hasPrefix("UF") {
                message = paymentErrorMessage
            } else if let reason = reason, reason.contains(":") {
                message = reason
                    .split(separator: ":")
                    .dropFirst()
                    .joined(separator: ":")
                    .trimmingCharacters(in: .whitespaces)
            } else {
                message = reason ?? paymentErrorMessage
            }
            return .showFailed(message: message)
            
        default:
            // handle any other unexpected statuses
            return nil
        }
    }


    private static func decodeBase64(url: String) -> String? {
        // Decode the base64 string into Data
        guard let decodedData = Data(base64Encoded: url),
              let decodedString = String(data: decodedData, encoding: .utf8) else {
            return nil // Return nil if decoding fails
        }
        return decodedString
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


extension Image {
    init(frameworkAsset name: String, isTemplate: Bool = false) {
        let bundle = Bundle.module
        let image = Image(name, bundle: bundle)
        self = isTemplate ? image.renderingMode(.template) : image.renderingMode(.original)
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
