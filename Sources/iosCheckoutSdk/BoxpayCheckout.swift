//
//  BoxpayCheckout.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 15/05/25.
//

import SwiftUI
import SDWebImageSVGCoder

public struct BoxpayCheckout : View {
    var token : String
    var shopperToken : String?
    var configurationOption : ConfigOptions?
    var onPaymentResult : (PaymentResultObject) -> Void
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = CheckoutViewModel()
    @State private var isCheckoutMainScreenFocused = false
    
    
    public init(
            token: String,
            shopperToken: String?,
            configurationOptions: ConfigOptions? = nil,
            onPaymentResult: @escaping (PaymentResultObject) -> Void
        ){
            CustomFontLoader.loadFonts()
            self.token = token
            self.shopperToken = shopperToken
            self.configurationOption = configurationOptions
            self.onPaymentResult = onPaymentResult
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
        }
    
    public var body: some View {
        // Replace this with your actual SDK UI
        MainCheckoutScreen(
            viewModel : viewModel,
            isCheckoutMainScreenFocused : $isCheckoutMainScreenFocused
        )
        .onAppear {
            if !viewModel.isInitialized {
                viewModel.initialize(token: token, shopperToken: shopperToken, config: configurationOption, callback: onPaymentResult)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onChange(of: isCheckoutMainScreenFocused) { focused in
            if focused {
                triggerPaymentStatusCallBack()
            }
        }
    }
    
    private func triggerPaymentStatusCallBack() {
        Task {
            let status = await viewModel.checkoutManager.getStatus()
            let transactionId = await viewModel.checkoutManager.getTransactionId()

            PaymentCallBackManager.shared.triggerPaymentResult(
                result: PaymentResultObject(status: status, transactionId: transactionId)
            )

            await viewModel.checkoutManager.clearAllFields()
            await viewModel.userDataManager.clearAllFields()
            presentationMode.wrappedValue.dismiss()
        }
    }
}
