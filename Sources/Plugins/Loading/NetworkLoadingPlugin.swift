//
//  NetworkLoadingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`MBProgressHUD`文档
/// https://github.com/jdg/MBProgressHUD

import Foundation
import Moya
import MBProgressHUD

/// 加载插件，基于MBProgressHUD封装
/// Loading plugin, based on MBProgressHUD package
public struct NetworkLoadingPlugin {
    
    public let options: Options
    
    public init(options: Options = .keyWindow) {
        self.options = options
    }
    
    /// 如果设置过`autoHide`请记得自己来关闭加载动画，倘若失败插件会帮你关闭，倘若均成功请自己来关闭
    /// If you have set `autoHide = false`, please remember to close the loading animation yourself.
    /// If it fails, the plug-in will help you close it. If it is successful, please close it yourself.
    public static func hideMBProgressHUD() {
        DispatchQueue.main.async {
            if let view = DisplayPosition.keyWindow() {
                MBProgressHUD.hide(for: view, animated: true)
            }
            if let vc = DisplayPosition.topViewController(), let view = vc.view {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }
}

extension NetworkLoadingPlugin {
    public struct Options {
        /// Display in the window position.
        public static let keyWindow: Options = .init(in: .keyWindow)
        
        /// Loading will not be automatically hidden and display window.
        public static let dontAutoHide: Options = .init(autoHide: false)
        
        /// Display super view.
        let displayView: UIView?
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        
        /// 是否需要自动隐藏Loading，可用于链式请求时刻，最开始的网络请求开启Loading，最末尾网络请求结束再移除Loading。
        /// Whether you need to automatically hide Loading, it can be used for chain request.
        /// The first network request starts loading, and the last network request ends and then removes the loading
        public let autoHideLoading: Bool
        
        public init(in type: DisplayPosition = .keyWindow, text: String = "", delay: Double = 0.0, autoHide: Bool = true) {
            self.displayView = type.displayView
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.autoHideLoading = autoHide
        }
        
        var hudCallback: ((_ hud: MBProgressHUD) -> Void)?
        /// 更改`hud`相关配置闭包
        /// Change `hud` related configuration closures.
        public mutating func setChangeHudParameters(block: @escaping (_ hud: MBProgressHUD) -> Void) {
            self.hudCallback = block
        }
    }
}

extension NetworkLoadingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Loading"
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        self.showText(options.displayLoadText)
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if options.autoHideLoading == false, case .success = result {
            return
        }
        if options.delayHideHUD > 0 {
            let concurrentQueue = DispatchQueue(label: "condy.loading.network.queue", attributes: .concurrent)
            concurrentQueue.asyncAfter(deadline: .now() + options.delayHideHUD) {
                NetworkLoadingPlugin.hideMBProgressHUD()
            }
        } else {
            NetworkLoadingPlugin.hideMBProgressHUD()
        }
    }
}

extension NetworkLoadingPlugin {
    
    /// Display the prompt text
    /// - Parameters:
    ///   - text: display content
    ///   - window: whether to display in the window
    ///   - delay: delay hiding time
    private func showText(_ text: String) {
        DispatchQueue.main.async {
            guard let view = self.options.displayView else {
                return
            }
            if let _ = MBProgressHUD.forView(view) {
                return
            }
            // Set Activity Indicator View to white for hud loading.
            let indicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
            indicatorView.color = UIColor.white
            
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
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
            
            // User defined the hud configuration.
            self.options.hudCallback?(hud)
        }
    }
}
