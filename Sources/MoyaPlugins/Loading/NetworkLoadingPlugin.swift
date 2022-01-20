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
    /// Do you need to display an error message, the default is empty
    let displayLoadText: String
    /// Delay hidden, the default is zero seconds
    let delayHideHUD: TimeInterval
    
    /// 是否需要自动隐藏Loading，可用于链式请求时刻
    /// 最开始的网络请求开启Loading，最末尾网络请求结束再移除Loading
    /// Whether you need to automatically hide Loading, it can be used for chain request.
    /// The first network request starts loading, and the last network request ends and then removes the loading
    public private(set) var autoHideLoading: Bool = true
    
    /// 更改`hud`相关配置闭包
    /// Change `hud` related configuration closures.
    public var changeHud: ((_ hud: MBProgressHUD) -> Void)? = nil
    
    public init(in window: Bool = true,
                text: String = "",
                delay hideHUD: TimeInterval = 0.0,
                autoHide loading: Bool = true) {
        self.displayInWindow = window
        self.displayLoadText = text
        self.delayHideHUD = hideHUD
        self.autoHideLoading = loading
    }
}

extension NetworkLoadingPlugin: PluginSubType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        
        self.showText(displayLoadText, window: displayInWindow, delay: 0)
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
    ///   - delay: 延迟隐藏时间
    private func showText(_ text: String, window: Bool, delay: TimeInterval) {
        DispatchQueue.main.async {
            guard let view = window ? RxNetworks.View.keyWindow :
                    RxNetworks.View.topViewController?.view else { return }
            if let _hud = MBProgressHUD.forView(view), _hud.tag == NetworkLoadingPlugin.LoadingHUDT {
                return
            }
            // 设置加载为白色
            let indicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicatorView.color = UIColor.white
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.tag = NetworkLoadingPlugin.LoadingHUDT
            hud.mode = MBProgressHUDMode.indeterminate
            hud.animationType = MBProgressHUDAnimation.zoom
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
            hud.bezelView.layer.cornerRadius = 14
            hud.detailsLabel.text = text
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 16)
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.textColor = UIColor.white
            if (delay > 0) {
                hud.hide(animated: true, afterDelay: delay)
            }
            if let changeHud = self.changeHud {
                changeHud(hud)
            }
        }
    }
    
    /// 隐藏加载
    private static func hideMBProgressHUD() {
        DispatchQueue.main.async {
            if let view = RxNetworks.View.keyWindow {
                NetworkLoadingPlugin.hideView(view)
            }
            if let vc = RxNetworks.View.topViewController, let view = vc.view {
                NetworkLoadingPlugin.hideView(view)
            }
        }
    }
    
    private static func hideView(_ view: UIView) {
        if let hud = MBProgressHUD.forView(view), hud.tag == NetworkLoadingPlugin.LoadingHUDT {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
