//
//  BoxpayCheckout.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 15/05/25.
//

import SwiftUI
import cross_platform_sdk

public struct BoxpayCheckout : View {
    var token : String
    var shopperToken : String?
    @Environment(\.presentationMode) var presentationMode
    
    
    public init(
            token: String,
            shopperToken: String?,
        ){
            self.token = token
            self.shopperToken = shopperToken
        }
    
    public var body: some View {
        // Replace this with your actual SDK UI
        
    }
    
    private func triggerPaymentStatusCallBack() {
        Task {

        
            presentationMode.wrappedValue.dismiss()
        }
    }
}
