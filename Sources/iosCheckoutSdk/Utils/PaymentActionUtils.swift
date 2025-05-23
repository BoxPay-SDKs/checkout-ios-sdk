//
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import Foundation
import SwiftUI

struct PaymentActionUtils {
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
    
}
