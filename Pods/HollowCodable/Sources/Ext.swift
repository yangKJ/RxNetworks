//
//  Ext.swift
//  CodableExample
//
//  Created by Condy on 2024/6/16.
//

import Foundation

extension Dictionary {
    
    /// Retrieves the value corresponding to the path in the dictionary.
    func getInnerValue(forKeyPath keyPath: String) -> Any? {
        guard keyPath.contains(".") else {
            return nil
        }
        let keys = keyPath.components(separatedBy: ".")
        var currentAny: Any = self
        for key in keys {
            if let currentDict = currentAny as? [String: Any] {
                if let value = currentDict[key] {
                    currentAny = value
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        return currentAny
    }
}

extension Collection {
    
    /// Safe protects the array from out of bounds by use of optional.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({ filter($0) }).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
    func removeFromEnd(_ count: Int) -> [Element]? {
        guard count >= 0 else {
            return nil
        }
        let endIndex = self.count - count
        guard endIndex >= 0 else {
            return nil
        }
        return Array(self.prefix(endIndex))
    }
}

extension HollowWrapper where Base == Data {
    
    func toJSONObject() -> Any? {
        try? JSONSerialization.jsonObject(with: base, options: .allowFragments)
    }
}

extension HollowWrapper where Base == String {
    
    /// Whether the string is empty after excluding white space and line feed string.
    var isEmpty2: Bool {
        base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func toJSONObject() -> Any? {
        guard base.starts(with: "{") || base.starts(with: "[") else {
            return nil
        }
        return base.data(using: .utf8).flatMap {
            try? JSONSerialization.jsonObject(with: $0, options: .allowFragments)
        }
    }
    
    func snakeCamelConvert() -> String? {
        let result: String
        if base.contains("_") {
            result = snakeToCamel()
        } else {
            result = camelToSnake()
        }
        if base == result {
            return nil
        }
        return result
    }
    
    func snakeToCamel() -> String {
        guard !base.isEmpty, let firstNonUnderscore = base.firstIndex(where: { $0 != "_" }) else {
            return base
        }
        let stringKey = base
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        while lastNonUnderscore > firstNonUnderscore, stringKey[lastNonUnderscore] == "_" {
            stringKey.formIndex(before: &lastNonUnderscore)
        }
        let keyRange = firstNonUnderscore ... lastNonUnderscore
        let leadingUnderscoreRange = stringKey.startIndex ..< firstNonUnderscore
        let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore) ..< stringKey.endIndex
        let components = stringKey[keyRange].split(separator: "_")
        let joinedString: String
        if components.count == 1 {
            joinedString = String(stringKey[keyRange])
        } else {
            joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
        }
        
        let result: String
        if leadingUnderscoreRange.isEmpty, trailingUnderscoreRange.isEmpty {
            result = joinedString
        } else if !leadingUnderscoreRange.isEmpty, !trailingUnderscoreRange.isEmpty {
            result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
        } else if !leadingUnderscoreRange.isEmpty {
            result = String(stringKey[leadingUnderscoreRange]) + joinedString
        } else {
            result = joinedString + String(stringKey[trailingUnderscoreRange])
        }
        return result
    }
    
    func camelToSnake() -> String {
        var chars = Array(base)
        for (i, char) in chars.enumerated().reversed() {
            if char.isUppercase {
                chars[i] = String.Element(char.lowercased())
                if i > 0 {
                    chars.insert("_", at: i)
                }
            }
        }
        return String(chars)
    }
    
    func firstLetterToLowercase() -> String {
        guard !base.isEmpty else {
            return base
        }
        return base.prefix(1).lowercased() + base.dropFirst()
    }
    
    func firstLetterToUppercase() -> String {
        guard !base.isEmpty else {
            return base
        }
        return base.prefix(1).uppercased() + base.dropFirst()
    }
    
    var isValidDecimal: Bool {
        let regex = "((([1-9]{1}[0-9]*(\\.)?)|(0(\\.)))[0-9]{0,2})|0"
        let presicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return presicate.evaluate(with: base)
    }
    
    /// Verify that the URL format is correct.
    var isValidLink: Bool {
        do {
            let dataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let options = NSRegularExpression.MatchingOptions(rawValue: 0)
            let res = dataDetector.matches(in: base, options: options, range: NSMakeRange(0, base.count))
            return res.count == 1 && res[0].range.location == 0 && res[0].range.length == base.count ? true : false
        } catch {
            return false
        }
    }
}

extension HollowWrapper where Base == Double {
    
    func string(minPrecision: Int16 = 2, maxPrecision: Int16 = 2) -> String? {
        let string = String(describing: base)
        let array = string.components(separatedBy: ".") // fix bug: 35623.56 loss of precision at ios 14.
        let decimal: NSDecimalNumber
        if array.count == 2 && (array.last?.count ?? 0) <= 2 {
            decimal = NSDecimalNumber(string: string)
        } else {
            decimal = NSDecimalNumber(value: base)
        }
        return decimal.hc.string(minPrecision: minPrecision, maxPrecision: maxPrecision)
    }
}

extension HollowWrapper where Base: NSDecimalNumber {
    
    func string(minPrecision: Int16 = 2, maxPrecision: Int16 = 2) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = Int(maxPrecision)
        formatter.minimumFractionDigits = Int(minPrecision)
        let rounding = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
                                              scale: maxPrecision,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        return formatter.string(from: base.rounding(accordingToBehavior: rounding))
    }
}
