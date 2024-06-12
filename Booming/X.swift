//
//  NetworkX.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public struct X {
    
    public static func mainScale() -> CGFloat {
        #if os(macOS)
        return NSScreen.main?.backingScaleFactor ?? 1.0
        #else
        return UIScreen.main.scale
        #endif
    }
    
    public static func keyWindow() -> WindowType? {
        #if os(macOS)
        return NSApplication.shared.keyWindow
        #else
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
        #endif
    }
    
    public static func createWindow() -> WindowType {
        #if os(macOS)
        let window = NSWindow()
        window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
        window.backingType = .buffered
        let width = NSScreen.main?.frame.midX ?? 1.0
        let height = NSScreen.main?.frame.midY ?? 1.0
        window.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: false)
        return window
        #else
        return UIWindow(frame: UIScreen.main.bounds)
        #endif
    }
    
    /// Maps data received from the signal into a JSON object.
    public static func mapJSON<T>(_ type: T.Type, named: String, forResource: String = "Booming") -> T? {
        guard let data = jsonData(named, forResource: forResource) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? T
    }
    
    /// Read json data
    public static func jsonData(_ named: String, forResource: String = "Booming") -> Data? {
        let bundle: Bundle?
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: "bundle") {
            bundle = Bundle.init(path: bundlePath)
        } else {
            bundle = Bundle.main
        }
        guard let path = ["json", "JSON", "Json"].compactMap({
            bundle?.path(forResource: named, ofType: $0)
        }).first else {
            return nil
        }
        let contentURL = URL(fileURLWithPath: path)
        return try? Data(contentsOf: contentURL)
    }
    
    public static func toJSON(form value: Any, prettyPrint: Bool = false) -> String? {
        if let data = value as? Data {
            return String(data: data, encoding: .utf8)
        }
        guard JSONSerialization.isValidJSONObject(value) else {
            return nil
        }
        var jsonData: Data? = nil
        if prettyPrint {
            jsonData = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
        } else {
            jsonData = try? JSONSerialization.data(withJSONObject: value, options: [])
        }
        guard let data = jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public static func toDictionary(form json: String) -> [String : Any]? {
        guard let jsonData = json.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let result = object as? [String : Any] else {
            return nil
        }
        return result
    }
}
