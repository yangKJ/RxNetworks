//
//  Logger.swift
//  CodableExample
//
//  Created by Condy on 2024/6/17.
//

import Foundation

extension Hollow {
    public struct Logger {
        public enum DebugMode: Int {
            case release = 0
            case debug = 1
        }
    }
}

extension Hollow.Logger {
    
    /// Set debug mode
    public static var debugMode: DebugMode {
        get { _mode }
        set { _mode = newValue }
    }
    
    /// Whether to enable assertions (effective in debug mode).
    /// Once enabled, an assertion will be performed where parsing fails, providing a more direct reminder to the user that parsing has failed at this point.
    public static var openErrorAssert: Bool = false
    
    private static var _mode = {
        #if DEBUG
        DebugMode.debug
        #else
        DebugMode.release
        #endif
    }()
    
    static var logIfNeeded: Bool {
        debugMode.rawValue > Hollow.Logger.DebugMode.release.rawValue
    }
    
    static func logDebug(_ error: Error) {
        if !logIfNeeded {
            return
        }
        if openErrorAssert {
            assert(false, "\(error)")
        }
        if let error = error as? DecodingError {
            printDecodingError(error)
        } else {
            print(error.localizedDescription)
        }
    }
    
    private static func printDecodingError(_ error: DecodingError) {
        var string: String = ""
        switch error {
        case .keyNotFound(let key, let context):
            let codingPath = codingPath(context: context)
            string += "\(key): No value associated with \(codingPath)"
        case .valueNotFound(_, let context):
            let key = context.codingPath.last?.stringValue ?? ""
            if key.starts(with: "Index ") {
                return
            }
            let codingPath = codingPath(context: context)
            string += "\(key): " + context.debugDescription + " from \(codingPath)"
        case .typeMismatch(_, let context):
            let key = context.codingPath.last?.stringValue ?? ""
            if key.starts(with: "Index ") {
                return
            }
            let codingPath = codingPath(context: context)
            string += "\(key): " + context.debugDescription + " from \(codingPath)"
        case .dataCorrupted(let context):
            let key = context.codingPath.last?.stringValue ?? ""
            if key.starts(with: "Index ") {
                return
            }
            let codingPath = codingPath(context: context)
            string += "\(key): " + context.debugDescription + " from \(codingPath)"
        default:
            return
        }
        print(string + " 👈🏻")
    }
    
    private static func codingPath(context: DecodingError.Context) -> String {
        let pattern = "Index \\d+" // 排除这种数据
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matchedKeys = context.codingPath.map({
            $0.stringValue
        }).filter { key in
            let range = NSRange(key.startIndex..<key.endIndex, in: key)
            return regex.firstMatch(in: key, options: [], range: range) == nil
        }
        return matchedKeys.joined(separator: ".")
    }
}
