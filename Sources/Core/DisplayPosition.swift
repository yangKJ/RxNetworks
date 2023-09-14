//
//  DisplayPosition.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/20.
//

import Foundation

/// 控件展示位置
public enum DisplayPosition {
    case view(UIView)
    case topView
    case keyWindow
    
    public var displayView: UIView? {
        switch self {
        case .view(let uIView):
            return uIView
        case .topView:
            return DisplayPosition.topViewController()?.view
        case .keyWindow:
            return DisplayPosition.keyWindow()
        }
    }
    
    public var isKeyWindow: Bool {
        switch self {
        case .keyWindow where DisplayPosition.keyWindow() != nil:
            return true
        default:
            return false
        }
    }
}

extension DisplayPosition {
    
    public static func keyWindowOrTopView(_ window: Bool) -> UIView? {
        window ? DisplayPosition.keyWindow() : DisplayPosition.topViewController()?.view
    }
    
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
        var vc = keyWindow()?.rootViewController
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
