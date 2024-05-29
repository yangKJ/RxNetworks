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
public struct NetworkWarningPlugin: PluginPropertiesable {
    let queue = DispatchQueue(label: "condy.warning.network.queue", attributes: .concurrent)
    
    public var plugins: APIPlugins = []
    
    public var key: String?
    
    public let options: Options
    
    public init(options: Options = .init()) {
        self.options = options
    }
}

extension NetworkWarningPlugin {
    public struct Options {
        /// The default duration.
        let duration: Double
        /// 是否会覆盖上次的错误展示，如果上次错误展示还在，新的错误展示是否需要覆盖上次。
        /// Whether it will overwrite the last error display,
        /// If the last error display is still there, whether the new error display needs to overwrite the last one.
        let coverLastToast: Bool
        
        public init(duration: Double = 1.0, cover: Bool = true) {
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
    
    public func lastNever(_ result: LastNeverResult, target: TargetType, onNext: @escaping LastNeverCallback) {
        result.mapResult(failure: { error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showText(error.localizedDescription)
            }
        })
        onNext(result)
    }
}

extension NetworkWarningPlugin {
    
    private func showText(_ text: String) {
        guard let key = self.key else {
            return
        }
        if self.options.coverLastToast, let vc = HUDs.readHUD(key: key) {
            (vc.showUpView as? MBProgressHUD)?.label.text = text
            return
        }
        let vc = LevelStatusBarWindowController()
        
        let hud = MBProgressHUD.showAdded(to: vc.view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.animationType = MBProgressHUDAnimation.zoom
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
        hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud.bezelView.layer.cornerRadius = 10
        hud.label.text = text
        hud.label.numberOfLines = 0
        hud.label.textColor = UIColor.white
        hud.completionBlock = self.options.completionBlock
        
        // User defined the hud configuration.
        self.options.hudCallback?(hud)
        
        vc.key = key
        vc.showUpView = hud
        vc.addedShowUpView = true
        vc.show()
        HUDs.saveHUD(key: key, viewController: vc)
        
        self.queue.asyncAfter(deadline: .now() + self.options.duration) {
            vc.close()
            HUDs.removeHUD(key: key)
        }
    }
}
