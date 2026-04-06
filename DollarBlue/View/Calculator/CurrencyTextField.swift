//
//  CurrencyTextField.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct CurrencyTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void = {}
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CurrencyTextField

        init(parent: CurrencyTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty {
                return true
            }

            let allowedCharacters = CharacterSet(charactersIn: "0123456789,.")
            guard string.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
                return false
            }
            return true
        }

        @objc
        func editingChanged(_ textField: UITextField) {
            let sanitizedText = CalculatorAmountFormatter.sanitize(textField.text ?? "")

            if textField.text != sanitizedText {
                textField.text = sanitizedText
            }

            parent.text = sanitizedText
        }

        @objc
        func submitTapped() {
            parent.onSubmit()
        }
    }

    final class AdaptiveTextField: UITextField {
        override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.width = UIView.noIntrinsicMetric
            return size
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = AdaptiveTextField()
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        textField.keyboardType = .decimalPad
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.backgroundColor = .clear
        textField.textColor = UIColor.label
        textField.tintColor = UIColor(named: "ColorGreenD") ?? UIColor.systemGreen
        textField.textAlignment = .right
        textField.font = .monospacedDigitSystemFont(ofSize: 26, weight: .semibold)
        textField.adjustsFontForContentSizeCategory = true
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 18
        textField.clearButtonMode = .never
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.smartQuotesType = .no
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.inputAccessoryView = makeAccessoryToolbar(coordinator: context.coordinator)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self

        if uiView.text != text {
            uiView.text = text
        }

        uiView.inputAccessoryView = makeAccessoryToolbar(coordinator: context.coordinator)

        if text.isEmpty {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: UIFont.systemFont(ofSize: 17, weight: .medium)
                ]
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func makeAccessoryToolbar(coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor(named: "ColorGreenD") ?? UIColor(red: 0.28, green: 0.56, blue: 0.25, alpha: 1)
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(
                title: "Calcular",
                style: .done,
                target: coordinator,
                action: #selector(Coordinator.submitTapped)
            )
        ]
        return toolbar
    }
}
