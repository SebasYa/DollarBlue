//
//  CalculatorInputSession.swift
//  DollarBlue
//
//  Created by Codex on 06/04/2026.
//

import Foundation

struct CalculatorInputSession: Equatable {
    private(set) var committedText = ""
    private(set) var committedValue: Double = 0
    private(set) var draftText = ""
    private(set) var isEditing = false

    private var snapshotText = ""
    private var snapshotValue: Double = 0

    mutating func startEditing() {
        guard !isEditing else {
            return
        }

        isEditing = true
        snapshotText = committedText
        snapshotValue = committedValue
        draftText = committedText
    }

    mutating func updateDraft(text: String) {
        draftText = CalculatorAmountFormatter.sanitize(text)
    }

    mutating func acceptDraft() {
        let value = CalculatorAmountFormatter.parse(draftText) ?? 0
        let formattedText = CalculatorAmountFormatter.committedText(for: value)

        committedValue = value
        committedText = formattedText
        draftText = formattedText
        snapshotText = formattedText
        snapshotValue = value
        isEditing = false
    }

    mutating func cancelDraft() {
        committedText = snapshotText
        committedValue = snapshotValue
        draftText = snapshotText
        isEditing = false
    }

    mutating func setCommittedAmount(_ amount: Double) {
        let normalizedValue = max(0, amount)
        let formattedText = CalculatorAmountFormatter.committedText(for: normalizedValue)

        committedValue = normalizedValue
        committedText = formattedText
        draftText = formattedText
        snapshotText = formattedText
        snapshotValue = normalizedValue
        isEditing = false
    }

    var activeText: String {
        isEditing ? draftText : committedText
    }
}

enum CalculatorAmountFormatter {
    static func sanitize(_ rawText: String) -> String {
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

    static func parse(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")

        guard !normalized.isEmpty else {
            return nil
        }

        return Double(normalized)
    }

    static func committedText(for value: Double) -> String {
        guard value > 0 else {
            return ""
        }

        return premiumEditableAmountString(value)
    }

    private static func normalizedIntegerPart(from rawValue: String) -> String {
        let trimmed = rawValue.drop(while: { $0 == "0" })

        if trimmed.isEmpty {
            return rawValue.isEmpty ? "" : "0"
        }

        return String(trimmed)
    }
}
