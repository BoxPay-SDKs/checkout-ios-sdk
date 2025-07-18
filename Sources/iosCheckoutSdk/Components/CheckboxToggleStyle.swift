//
//  CheckboxToggleStyle.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 18/07/25.
//

import SwiftUI
import RealityKit


struct CheckboxToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    let enabledColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? enabledColor : .secondary)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
            configuration.label
        }
        .disabled(!isEnabled)
    }
}
