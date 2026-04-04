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
    @Binding var value: Double
    var placeholder: String
    
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
            let sanitizedText = sanitize(textField.text ?? "")

            if textField.text != sanitizedText {
                textField.text = sanitizedText
            }

            parent.text = sanitizedText
            parent.value = parseValue(from: sanitizedText) ?? 0
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            guard parent.value > 0 else {
                parent.text = ""
                textField.text = ""
                return
            }

            let formattedText = premiumEditableAmountString(parent.value)
            parent.text = formattedText
            textField.text = formattedText
        }

        private func sanitize(_ rawText: String) -> String {
            let cleaned = rawText
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: " ", with: "")
                .filter { $0.isNumber || $0 == "," || $0 == "." }

            guard !cleaned.isEmpty else {
                return ""
            }

            let separators = cleaned.indices.filter { index in
                cleaned[index] == "," || cleaned[index] == "."
            }

            if let decimalIndex = separators.last {
                let integerDigits = cleaned[..<decimalIndex].filter(\.isNumber)
                let decimalDigits = cleaned[cleaned.index(after: decimalIndex)...]
                    .filter(\.isNumber)

                if decimalDigits.count > 2 {
                    return normalizedIntegerPart(from: String(cleaned.filter(\.isNumber)))
                }

                let integerPart = normalizedIntegerPart(from: String(integerDigits))
                let decimalPart = String(decimalDigits.prefix(2))

                if decimalPart.isEmpty {
                    return "\(integerPart),"
                }

                return "\(integerPart),\(decimalPart)"
            }

            return normalizedIntegerPart(from: String(cleaned.filter(\.isNumber)))
        }

        private func normalizedIntegerPart(from rawValue: String) -> String {
            let trimmed = rawValue.drop(while: { $0 == "0" })

            if trimmed.isEmpty {
                return rawValue.isEmpty ? "" : "0"
            }

            return String(trimmed)
        }

        private func parseValue(from text: String) -> Double? {
            let normalized = text.replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")

            guard !normalized.isEmpty else {
                return nil
            }

            return Double(normalized)
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
        textField.minimumFontSize = 13
        textField.clearButtonMode = .never
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
        if uiView.text != text {
            uiView.text = text
        }

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
}
