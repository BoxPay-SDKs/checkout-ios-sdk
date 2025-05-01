//
//  BoxpayLoaderView.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 15/04/25.
//

import SwiftUI
import Lottie

struct BoxpayLoaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            LottieView(animation: .named("boxpayLogo"))
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .frame(width: 100, height: 100)
            Text("Secured by")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(Color(hex: "#888888"))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
