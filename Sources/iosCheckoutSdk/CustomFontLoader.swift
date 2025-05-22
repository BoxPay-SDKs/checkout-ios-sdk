//
//  FontLoader.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 20/05/25.
//


import UIKit
import CoreGraphics

private class FontLoader {
    public static func loadFont(named fontName: String, withExtension ext: String = "otf", from bundle: Bundle) {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: ext) else {
            return
        }

        guard let dataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(dataProvider) else {
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}

public struct CustomFontLoader {
    public static func loadFonts() {
        FontLoader.loadFont(named: "Poppins-Regular", from: .module)
        FontLoader.loadFont(named: "Poppins-Medium", from: .module)
        FontLoader.loadFont(named: "Poppins-Bold", from: .module)
        FontLoader.loadFont(named: "Poppins-SemiBold", from: .module)
        FontLoader.loadFont(named: "Poppins-ExtraBold", from: .module)
        FontLoader.loadFont(named: "Inter-Regular", from: .module)
        FontLoader.loadFont(named: "Inter-Medium", from: .module)
        FontLoader.loadFont(named: "Inter-Bold", from: .module)
        FontLoader.loadFont(named: "Inter-SemiBold", from: .module)
        FontLoader.loadFont(named: "Inter-ExtraBold", from: .module)
    }
}
