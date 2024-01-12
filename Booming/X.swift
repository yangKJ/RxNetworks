//
//  NetworkX.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

public struct X {
    
    /// Maps data received from the signal into a JSON object.
    public static func mapJSON<T>(_ type: T.Type, named: String, forResource: String = "RxNetworks") -> T? {
        guard let data = jsonData(named, forResource: forResource) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? T
    }
    
    /// Read json data
    public static func jsonData(_ named: String, forResource: String = "RxNetworks") -> Data? {
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
        return String(data: data ,encoding: .utf8)
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

// MARK: - HUD
extension X {
    /// 移除窗口所有HUD
    public static func removeAllAtLevelStatusBarWindow() {
        SharedDriver.shared.removeAllAtLevelStatusBarWindow()
    }
    
    /// 移除所有加载HUD
    public static func removeLoadingHUDs() {
        SharedDriver.shared.removeLoadingHUDs()
    }
    
    public static func readHUD(key: String) -> LevelStatusBarWindowController? {
        SharedDriver.shared.readHUD(key: key)
    }
    
    public static func saveHUD(key: String, window vc: LevelStatusBarWindowController) {
        SharedDriver.shared.saveHUD(key: key, window: vc)
    }
    
    @discardableResult
    public static func removeHUD(key: String?) -> LevelStatusBarWindowController? {
        SharedDriver.shared.removeHUD(key: key)
    }
}
