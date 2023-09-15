//
//  NetworkWarningPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`Toast_Swift`文档
/// https://github.com/scalessec/Toast-Swift

import Foundation
import Moya
import MBProgressHUD

/// 自动提示插件，基于MBProgressHUD封装
/// Warning plugin, based on MBProgressHUD package
public struct NetworkWarningPlugin {
    
    public let options: Options
    
    public init(options: Options = .keyWindow) {
        self.options = options
    }
}

extension NetworkWarningPlugin {
    public struct Options {
        /// Display in the window position.
        public static let keyWindow: Options = .init(in: .keyWindow)
        
        /// The default duration. Used for the `makeToast` and `showToast` methods that don't require an explicit duration.
        let duration: Double
        /// Display super view.
        let displayView: UIView?
        
        /// 是否会覆盖上次的错误展示，如果上次错误展示还在，新的错误展示是否需要覆盖上次。
        /// Whether it will overwrite the last error display,
        /// If the last error display is still there, whether the new error display needs to overwrite the last one.
        let coverLastToast: Bool
        
        public init(in type: DisplayPosition = .keyWindow, duration: Double = 1.0, cover: Bool = true) {
            self.displayView = type.displayView
            self.duration = duration
            self.coverLastToast = cover
        }
        
        var hudCallback: ((_ hud: MBProgressHUD) -> Void)?
        
        /// Change hud related configuration closures.
        public mutating func setChangeHudParameters(block: @escaping (_ hud: MBProgressHUD) -> Void) {
            self.hudCallback = block
        }
        
        var completionBlock: MBProgressHUDCompletionBlock?
        
        public mutating func setHudCompletionBlock(block: @escaping MBProgressHUDCompletionBlock) {
            self.completionBlock = block
        }
    }
}

extension NetworkWarningPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Warning"
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .failure(let error) = result {
            self.showText(error.localizedDescription)
        }
    }
}

extension NetworkWarningPlugin {
    
    private func showText(_ text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let view = self.options.displayView else {
                return
            }
            if self.options.coverLastToast {
                MBProgressHUD.hide(for: view, animated: true)
            }
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.animationType = MBProgressHUDAnimation.zoom
            hud.removeFromSuperViewOnHide = true
            hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
            hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
            hud.bezelView.layer.cornerRadius = 10
            hud.label.text = text
            hud.label.numberOfLines = 0
            hud.label.textColor = UIColor.white
            hud.hide(animated: true, afterDelay: self.options.duration)
            hud.completionBlock = self.options.completionBlock
            
            // User defined the hud configuration.
            self.options.hudCallback?(hud)
        }
    }
}
