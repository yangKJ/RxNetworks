//
//  NetworkLoadingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

///`MBProgressHUD`文档
/// https://github.com/jdg/MBProgressHUD

import Foundation
import Moya
import MBProgressHUD

/// 加载插件，基于MBProgressHUD封装
/// Load the plug-in, based on MBProgressHUD package
public final class NetworkLoadingPlugin {
    
    // 用于区分其他插件等是否使用过`MBProgressHUD`
    // Used to distinguish whether other plugins have used `MBProgressHUD`
    public static let LoadingHUDT = 5200123
    
    /// Whether to display the Window again, the default is YES
    let displayInWindow: Bool
    /// Do you need to display the loading chrysanthemum, the default is YES
    let displayLoading: Bool
    /// Do you need to display an error message, the default is empty
    let displayLoadText: String
    /// Delay hidden, the default is zero seconds
    let delayHideHUD: TimeInterval
    
    /// 是否需要自动隐藏Loading，可用于链式请求时刻
    /// 最开始的网络请求开启Loading，最末尾网络请求结束再移除Loading
    /// Whether you need to automatically hide Loading, it can be used for chain request.
    /// The first network request starts loading, and the last network request ends and then removes the loading
    public private(set) var autoHideLoading: Bool = true
    
    public init(displayInWindow: Bool = true,
                displayLoading: Bool = true,
                displayLoadText: String = "",
                delayHideHUD: TimeInterval = 0.0,
                autoHideLoading: Bool = true) {
        self.displayInWindow = displayInWindow
        self.displayLoading = displayLoading
        self.displayLoadText = displayLoadText
        self.delayHideHUD = delayHideHUD
        self.autoHideLoading = autoHideLoading
    }
}

extension NetworkLoadingPlugin: PluginSubType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if displayLoading {
            NetworkLoadingPlugin.showText(displayLoadText, display: displayInWindow, delay: 0)
        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if autoHideLoading == false {
            switch result {
            case .success(_): return
            case .failure(_): break
            }
        }
        if delayHideHUD > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + delayHideHUD) {
                NetworkLoadingPlugin.hideMBProgressHUD()
            }
        } else {
            NetworkLoadingPlugin.hideMBProgressHUD()
        }
    }
}

extension NetworkLoadingPlugin {
    
    /// 显示提示文本
    /// - Parameters:
    ///   - text: 显示内容
    ///   - window: 是否显示在窗口
    ///   - time: 延迟隐藏时间
    public static func showText(_ text: String, display window: Bool, delay hideTime: TimeInterval) {
        DispatchQueue.main.async {
            guard let view = window ? NetworkLoadingPlugin.keyWindow :
                    NetworkLoadingPlugin.topViewController?.view else { return }
            if let _hud = MBProgressHUD.forView(view), _hud.tag == NetworkLoadingPlugin.LoadingHUDT {
                return
            }
            // 设置加载为白色
            let indicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicatorView.color = UIColor.white
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.tag = NetworkLoadingPlugin.LoadingHUDT
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
            hud.bezelView.layer.cornerRadius = 14
            hud.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
            hud.backgroundView.color = UIColor(red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 0.1)
            hud.animationType = MBProgressHUDAnimation.fade
            hud.detailsLabel.text = text
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 16)
            hud.label.numberOfLines = 0
            hud.mode = MBProgressHUDMode.indeterminate
            /// 编码顺序很重要，只有在这里设置颜色才生效
            hud.detailsLabel.textColor = UIColor.white
            hud.label.font = UIFont.systemFont(ofSize: 14)
            if (hideTime > 0) {
                hud.hide(animated: true, afterDelay: hideTime)
            }
        }
    }
    
    /// 隐藏加载
    public static func hideMBProgressHUD() {
        DispatchQueue.main.async {
            if let view = NetworkLoadingPlugin.keyWindow {
                NetworkLoadingPlugin.hideView(view)
            }
            if let vc = NetworkLoadingPlugin.topViewController, let view = vc.view {
                NetworkLoadingPlugin.hideView(view)
            }
        }
    }
    
    private static func hideView(_ view: UIView) {
        if let hud = MBProgressHUD.forView(view), hud.tag == NetworkLoadingPlugin.LoadingHUDT {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    private static var keyWindow: UIWindow? {
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
    
    private static var topViewController: UIViewController? {
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
