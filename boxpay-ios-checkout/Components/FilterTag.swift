//
//  FilterTag.swift
//  boxpay-ios-checkout
//
//  Created by Ishika Bansal on 08/05/25.
//

import SwiftUICore

struct FilterTag: View {
    var filterText: String

    var body: some View {
        Text(filterText)
            .font(.custom("Poppins-Medium", size: 10))
            .foregroundColor(Color(hex: "#EB2F96"))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "#FFADD2"))
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex:"#FFF0F6"))
                    )
            )
    }
}
