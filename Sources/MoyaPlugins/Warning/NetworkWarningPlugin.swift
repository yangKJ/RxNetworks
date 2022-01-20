//
//  NetworkWarningPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

import Foundation
import Moya
import MBProgressHUD

/// 自动提示插件
/// Indicator plug-in, the plug-in has been set for global use
public final class NetworkWarningPlugin {
    
    // 用于区分其他插件等是否使用过`MBProgressHUD`
    // Used to distinguish whether other plugins have used `MBProgressHUD`
    public static let WarningHUDT = 5200124
    
    /// Whether to display the Window again, the default is YES
    let displayInWindow: Bool
    /// Show time
    let displayTime: TimeInterval
    
    /// 是否会覆盖上次的错误展示，
    /// 如果上次错误展示还在，新的错误展示是否需要覆盖上次
    /// Whether it will overwrite the last error display,
    /// If the last error display is still there, whether the new error display needs to overwrite the last one
    let coverLastHUD: Bool
    
    /// 更改`hud`相关配置闭包
    /// Change `hud` related configuration closures.
    public var changeHud: ((_ hud: MBProgressHUD) -> Void)? = nil
    
    public init(in window: Bool = true, time: TimeInterval = 1, cover: Bool = true) {
        self.displayInWindow = window
        self.displayTime = time
        self.coverLastHUD = cover
    }
}

extension NetworkWarningPlugin: PluginSubType {
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(_):
            break
        case let .failure(error):
            self.showText(error.localizedDescription)
        }
    }
}

extension NetworkWarningPlugin {
    
    private func showText(_ text: String) {
        DispatchQueue.main.async {
            guard let view = self.displayInWindow ? RxNetworks.View.keyWindow :
                    RxNetworks.View.topViewController?.view else { return }
            if let _hud = MBProgressHUD.forView(view), _hud.tag == NetworkWarningPlugin.WarningHUDT {
                if self.coverLastHUD {
                    _hud.detailsLabel.text = text
                    _hud.hide(animated: true, afterDelay: self.displayTime)
                }
                return
            }
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.tag = NetworkWarningPlugin.WarningHUDT
            hud.mode = MBProgressHUDMode.text
            hud.animationType = MBProgressHUDAnimation.zoom
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
            hud.bezelView.layer.cornerRadius = 14
            hud.detailsLabel.text = text
            hud.detailsLabel.numberOfLines = 0
            hud.detailsLabel.textColor = UIColor.white
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 16)
            hud.hide(animated: true, afterDelay: self.displayTime)
            if let changeHud = self.changeHud {
                changeHud(hud)
            }
        }
    }
}
