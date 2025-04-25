//
//  CommonFunction.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 24/04/25.
//
// CommonFunctions.swift
import Foundation

struct CommonFunctions {
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
    
    
    static func handle(
        timeStamp:String?,
        reasonCode: String?,
        reason: String?,
        methodType: String,
        response : PaymentActionResponse,
        shopperVpa:String
    ) -> PaymentAction? {
        let checkoutManager = CheckoutManager.shared

        if checkoutManager.getStatus() == "REQUIRESACTION"{
            if let actions = response.action , !actions.isEmpty, !methodType.isEmpty {
                let type = actions.first?.type
                
                if methodType.uppercased() == "UPI" {
                    let url = actions.first?.url
                    let base64 = decodeBase64(url: url ?? "")
                    return .openIntentUrl(url: base64 ?? "")
                } else {
                    if(type == "html") {
                        return .openWebViewHTML(htmlString: actions.first?.htmlPageString ?? "")
                    }
                    return .openWebViewUrl(url: actions.first?.url ?? "")
                }
            } else if(methodType.uppercased() == "UPI") {
                return .openUpiTimer(shopperVpa: shopperVpa)
            }
        }
        else if ["FAILED", "REJECTED"].contains(checkoutManager.getStatus()) {
            let message: String
            if let code = reasonCode, !code.hasPrefix("UF") {
                message = checkoutManager.getpaymentErrorMessage()
            } else {
                if let reason = reason, reason.contains(":") {
                    message = reason.split(separator: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                } else {
                    message = reason ?? checkoutManager.getpaymentErrorMessage()
                }
            }
            return .showFailed(message: message)
        }
        else if ["APPROVED", "SUCCESS", "PAID"].contains(checkoutManager.getStatus()) {
            return .showSuccess(timestamp: timeStamp ?? "")
        }
        else if checkoutManager.getStatus() == "EXPIRED" {
            return .showExpired
        }
        else if checkoutManager.getStatus() == "PENDING" , methodType.uppercased() == "UPI" {
            let message: String
            if let code = reasonCode, !code.hasPrefix("UF") {
                message = checkoutManager.getpaymentErrorMessage()
            } else {
                if let reason = reason, reason.contains(":") {
                    message = reason.split(separator: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                } else {
                    message = reason ?? checkoutManager.getpaymentErrorMessage()
                }
            }
            return .showFailed(message: message)
        }
        return nil
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

