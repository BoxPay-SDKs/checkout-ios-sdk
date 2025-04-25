//
//  ConfigurationOption.swift
//  checkout-ios-sdk
//
//  Created by Ishika Bansal on 15/04/25.
//


public enum ConfigurationOption: String {
    case showBoxpaySuccessScreen = "SHOW_BOXPAY_SUCCESS_SCREEN"
    case enableTextEnv = "ENABLE_TEST_ENV"
}

public typealias ConfigOptions = [ConfigurationOption: Bool]