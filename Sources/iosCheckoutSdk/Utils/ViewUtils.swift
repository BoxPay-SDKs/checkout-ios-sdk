//
//  ViewUtils.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/07/25.
//

import SwiftUI

extension View {
    func commonCardStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal, 16)
    }
}
