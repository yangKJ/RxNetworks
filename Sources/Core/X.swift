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

extension X {
    
    public static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    public static func topViewController() -> UIViewController? {
        let window = UIApplication.shared.delegate?.window
        guard window != nil, let rootViewController = window?!.rootViewController else {
            return nil
        }
        return self.getTopViewController(controller: rootViewController)
    }
    
    public static func getTopViewController(controller: UIViewController) -> UIViewController {
        if let presentedViewController = controller.presentedViewController {
            return self.getTopViewController(controller: presentedViewController)
        } else if let navigationController = controller as? UINavigationController {
            if let topViewController = navigationController.topViewController {
                return self.getTopViewController(controller: topViewController)
            }
            return navigationController
        } else if let tabbarController = controller as? UITabBarController {
            if let selectedViewController = tabbarController.selectedViewController {
                return self.getTopViewController(controller: selectedViewController)
            }
            return tabbarController
        } else {
            return controller
        }
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
