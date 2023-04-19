//
//  NetworkX.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import UIKit

public struct X {
    public struct View { }
}

extension X {
    
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

extension X.View {
    
    public static var keyWindow: UIWindow? {
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
    
    public static var topViewController: UIViewController? {
        var vc = keyWindow?.rootViewController
        if let presentedController = vc as? UITabBarController {
            vc = presentedController.selectedViewController
        }
        while let presentedController = vc?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                vc = presentedController.selectedViewController
            } else {
                vc = presentedController
            }
        }
        return vc
    }
}
