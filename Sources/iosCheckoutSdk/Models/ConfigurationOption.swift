//
//  ConfigurationOption.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 13/05/25.
//



public enum ConfigurationOption: String {
    case showBoxpaySuccessScreen = "SHOW_BOXPAY_SUCCESS_SCREEN"
    case enableTextEnv = "ENABLE_TEST_ENV"
    case showUPIQROnLoad = "SHOW_UPI_QR_ON_LOAD"
}

public typealias ConfigOptions = [ConfigurationOption: Bool]
