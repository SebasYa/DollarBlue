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
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CurrencyTextField

        init(parent: CurrencyTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let text = textField.text as NSString? else { return true }
            let newText = text.replacingCharacters(in: range, with: string)
            let digits = CharacterSet.decimalDigits
            let digitText = newText.unicodeScalars.filter { digits.contains($0) }.map { String($0) }.joined()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.groupingSeparator = "."
            formatter.decimalSeparator = ","
            formatter.maximumFractionDigits = 2
            
            let number = (Double(digitText) ?? 0) / 100
            textField.text = formatter.string(from: NSNumber(value: number))
            
            if let doubleValue = Double(digitText) {
                parent.value = doubleValue / 100
            }
            
            parent.text = textField.text ?? ""
            return false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            doneTapped(textField)
        }
        
        @objc func doneTapped(_ textField: UITextField) {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.maximumFractionDigits = 2
            formatter.decimalSeparator = ","
            formatter.groupingSeparator = "."
            
            if parent.text.isEmpty || parent.text == "0.00" {
                parent.text = parent.placeholder
                parent.value = 0
            } else {
                if let value = formatter.number(from: parent.text)?.doubleValue {
                    parent.value = value
                    parent.text = formatter.string(from: NSNumber(value: value)) ?? ""
                }
            }
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
    }
    
    @Binding var text: String
    @Binding var value: Double
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.textColor = UIColor(named: "ColorGreenD")
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: context.coordinator,
                                         action: #selector(Coordinator.doneTapped))
        doneButton.tintColor = UIColor(named: "ColorGreenD")
        toolbar.setItems([UIBarButtonItem.flexibleSpace(), doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if text.isEmpty || text == "0.00" {
            uiView.placeholder = placeholder
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
