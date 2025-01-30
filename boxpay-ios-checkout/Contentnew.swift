//
//  Contentnew.swift
//  boxpay-ios-checkout
//
//  Created by ankush on 16/01/25.
//

import SwiftUI

struct ContentNew: View {
    var body: some View {
        VStack {
            Image(systemName: "chevron.right")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentNew()
    }
}
