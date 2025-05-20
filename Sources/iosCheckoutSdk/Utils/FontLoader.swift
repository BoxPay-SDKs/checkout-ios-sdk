//
//  FontLoader.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 20/05/25.
//


import UIKit
import CoreGraphics

private class FontLoader {
    public static func loadFont(named fontName: String, withExtension ext: String = "ttf", from bundle: Bundle) {
        print("🔍 Looking for: Fonts/\(fontName).\(ext)")
        guard let fontURL = bundle.url(forResource: fontName, withExtension: ext, subdirectory: "Fonts") else {
            print("❌ Could not find font: \(fontName).\(ext)")
            return
        }

        guard let dataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(dataProvider) else {
            print("❌ Could not create font from data provider")
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("❌ Failed to register font: \(error?.takeUnretainedValue().localizedDescription ?? "unknown error")")
        } else {
            print("✅ Font registered: \(font.fullName ?? fontName as CFString)")
        }
    }
}

public class CustomFontLoader {
    
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
