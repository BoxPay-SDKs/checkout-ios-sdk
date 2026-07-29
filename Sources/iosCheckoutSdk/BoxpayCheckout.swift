//
//  BoxpayCheckout.swift
//  iosCheckoutSdk
//
//  Created by Ishika Bansal on 15/05/25.
//

import UIKit
import cross_platform_sdk

public enum ConfigurationOptions: Hashable {
    case enableSandboxEnv
    case showBoxpaySuccessScreen
    case showBoxpayFailedScreen
    case showUpiQrOnLoad
    case isSiCheckboxEnabled
    case isSiCheckboxChecked
    case isBoxpayProceedButtonVisible
}

public struct UIConfiguration {
    public let ctaBorderRadius: Int32
    public let focusedTextInputBorderColor: String
    public let unfocusedTextInputBorderColor: String
    public let fontFamily: String

    public init(
        ctaBorderRadius: Int32 = 12,
        focusedTextInputBorderColor: String = "",
        unfocusedTextInputBorderColor: String = "",
        fontFamily: String = ""
    ) {
        self.ctaBorderRadius = ctaBorderRadius
        self.focusedTextInputBorderColor = focusedTextInputBorderColor
        self.unfocusedTextInputBorderColor = unfocusedTextInputBorderColor
        self.fontFamily = fontFamily
    }
}

public class BoxpayCheckout {

    private let token: String
    private let shopperToken: String
    private let onPaymentResult: (SDKPaymentResponse) -> Void
    private let configurationOptions: [ConfigurationOptions: Bool]?
    private let uiConfiguration: UIConfiguration?

    public init(
        token: String,
        onPaymentResult: @escaping (SDKPaymentResponse) -> Void,
        shopperToken: String = "",
        configurationOptions: [ConfigurationOptions: Bool]? = nil,
        uiConfiguration: UIConfiguration? = nil
    ) {
        self.token = token
        self.shopperToken = shopperToken
        self.onPaymentResult = onPaymentResult
        self.configurationOptions = configurationOptions
        self.uiConfiguration = uiConfiguration
    }

    private func flag(_ option: ConfigurationOptions) -> Bool {
        configurationOptions?[option] ?? false
    }

    /// Equivalent to Android's `display()` — presents the full checkout flow.
    public func display(from presentingViewController: UIViewController) {
        SDKPaymentResponseHandler.shared.set(handler: onPaymentResult)

        let checkoutVC = BoxPayViewControllerKt.BoxPayViewController(
            token: token,
            isTestEnv: flag(.enableSandboxEnv),
            shopperToken: shopperToken,
            isSuccessScreenVisible: flag(.showBoxpaySuccessScreen),
            isFailedScreenVisible: flag(.showBoxpayFailedScreen),
            showQROnLoad: flag(.showUpiQrOnLoad),
            ctaBorderRadius: uiConfiguration?.ctaBorderRadius ?? 12,
            isSICheckBoxChecked: flag(.isSiCheckboxChecked),
            isSICheckBoxEnabled: flag(.isSiCheckboxEnabled),
            focusedTextInputBorderColor: uiConfiguration?.focusedTextInputBorderColor ?? "",
            unfocusedTextInputBorderColor: uiConfiguration?.unfocusedTextInputBorderColor ?? "",
            onDismiss: { [weak presentingViewController] in
                presentingViewController?.dismiss(animated: true)
            },
            fontFamily: uiConfiguration?.fontFamily ?? ""
        )

        DispatchQueue.main.async {
            let container = UIViewController()
                    container.view.backgroundColor = .systemBackground

                    container.addChild(checkoutVC)
                    container.view.addSubview(checkoutVC.view)
                    checkoutVC.didMove(toParent: container)

                    checkoutVC.view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        checkoutVC.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
                        checkoutVC.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
                        checkoutVC.view.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor),
                        checkoutVC.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor)
                    ])

                    container.modalPresentationStyle = .fullScreen
                    presentingViewController.present(container, animated: true)
        }
    }
}
