//
//  ImageUtils.swift
//  checkout_ios_sdk
//
//  Created by Ishika Bansal on 22/05/25.
//

import SwiftUI

extension Image {
    init(frameworkAsset name: String, isTemplate: Bool = false) {
        let bundle = Bundle.module
        let image = Image(name, bundle: bundle)
        self = isTemplate ? image.renderingMode(.template) : image.renderingMode(.original)
    }
}
