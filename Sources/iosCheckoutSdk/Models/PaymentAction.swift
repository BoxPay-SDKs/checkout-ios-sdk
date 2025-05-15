//
//  PaymentAction.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//



enum PaymentAction {
    case openWebViewUrl(url: String)
    case openWebViewHTML(htmlString:String)
    case openIntentUrl(url: String)
    case openUpiTimer(shopperVpa:String)
    case showFailed(message: String)
    case showSuccess(timestamp: String)
    case showExpired
}


struct PaymentActionResponse {
    let action : [GeneralActionResponse]?
}
