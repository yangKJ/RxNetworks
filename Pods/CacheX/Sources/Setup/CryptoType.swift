//
//  CryptoType.swift
//  CacheX
//
//  Created by Condy on 2023/3/28.
//

import Foundation
import CommonCrypto

public enum CryptoType {
    case md5
    case sha1
    case base58
    /// 用户自定义命名处理，这里不能包含操作符`/`和`.`
    case user((_ key: String) -> String)
}

extension CryptoType {
    
    /// Encryption processing.
    /// - Parameter key: String to be encrypted.
    /// - Returns: Encrypted string.
    public func encryptedString(with key: String) -> String {
        switch self {
        case .md5:
            return CryptoType.MD5.md5(string: key)
        case .sha1:
            return CryptoType.SHA.sha1(string: key)
        case .base58:
            return CryptoType.Base58.base58Encoded(string: key)
        case .user(let callback):
            return callback(key)
        }
    }
}

extension CryptoType {
    struct MD5 { }
    struct SHA { }
    struct Base58 { }
}

extension CryptoType.MD5 {
    
    static func md5(string: String) -> String {
        let ccharArray = string.cString(using: String.Encoding.utf8)
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
        return uint8Array.reduce("") { $0 + String(format: "%02X", $1) }
    }
}

extension CryptoType.SHA {
    
    static func sha1(string: String) -> String {
        guard let data = string.data(using: String.Encoding.utf8) else {
            return string
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        })
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension CryptoType.Base58 {
    
    private static let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    
    static func base58Encoded(string: String) -> String {
        guard let data = string.data(using: String.Encoding.utf8) else {
            return string
        }
        var bytes = [UInt8](data)
        var zerosCount = 0
        var length = 0
        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }
        bytes.removeFirst(zerosCount)
        let size = bytes.count * 138 / 100 + 1
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0
            for j in 0...base58.count-1 where carry != 0 || i < length {
                carry += 256 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }
            assert(carry == 0)
            length = i
        }
        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)
        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }
        for b in base58 {
            str = "\(str)\(base58Alphabet[String.Index(utf16Offset: Int(b), in: base58Alphabet)])"
        }
        return str
    }
}
