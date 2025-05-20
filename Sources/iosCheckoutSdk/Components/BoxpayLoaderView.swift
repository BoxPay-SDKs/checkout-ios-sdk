//
//  BoxpayLoaderView.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//


import SwiftUI
import Lottie

struct BoxpayLoaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            LottieView(animation: .named("BoxpayLogo", bundle: .module))
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .frame(width: 100, height: 100)
            Text("Secured by")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(Color(hex: "#888888"))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
