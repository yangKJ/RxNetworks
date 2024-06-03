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
public struct NetworkLoadingPlugin: HasKeyAndDelayPropertyProtocol {
    
    public var key: String?
    
    public var delay: Double {
        options.delayHideHUD
    }
    
    public var options: NetworkLoadingPlugin.Options
    
    public init(options: NetworkLoadingPlugin.Options = .loading) {
        self.options = options
    }
    
    /// Hide the loading hud.
    public func hideMBProgressHUD() {
        let vc = HUDs.removeHUD(key: key)
        vc?.close()
    }
}

extension NetworkLoadingPlugin {
    public struct Options {
        /// Default text hud display loading hud view controller.
        public static let loading = Options.init(text: "正在加载...")
        /// Loading will not be automatically hidden and display window.
        public static let dontAutoHide = Options.init(text: "", autoHide: false)
        
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        /// Do you need to automatically hide the loading hud.
        let autoHideLoading: Bool
        
        public init(text: String = "", delay: Double = 0.0, autoHide: Bool = true) {
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.autoHideLoading = autoHide
        }
        
        var hudCallback: ((_ hud: MBProgressHUD) -> Void)?
        
        /// Change hud related configuration closures.
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
        DispatchQueue.main.async {
            self.showHUD()
        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if (hudViewController?.subtractLoadingCount() ?? 0) <= 0, options.autoHideLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + options.delayHideHUD) {
                if let hud = hudViewController, hud.canRemoveThisHud {
                    self.hideMBProgressHUD()
                }
            }
        }
    }
}

extension NetworkLoadingPlugin {
    
    private var hudViewController: LoadingHudViewController? {
        HUDs.readHUD(suffix: pluginName).first as? LoadingHudViewController
    }
    
    private func showHUD() {
        if let vc = hudViewController {
            (vc.showUpView as? MBProgressHUD)?.detailsLabel.text = options.displayLoadText
            vc.addedLoadingCount()
        } else {
            let vc = LoadingHudViewController(createShowUpViewCallback: {
                // Set Activity Indicator View to white for hud loading.
                let indicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
                indicatorView.color = UIColor.white
                
                let hud = MBProgressHUD.init(frame: .zero)//showAdded(to: vc.view, animated: true)
                hud.mode = MBProgressHUDMode.indeterminate
                hud.animationType = MBProgressHUDAnimation.zoom
                hud.removeFromSuperViewOnHide = true
                hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
                hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
                hud.bezelView.layer.cornerRadius = 14
                hud.detailsLabel.text = options.displayLoadText
                hud.detailsLabel.font = UIFont.systemFont(ofSize: 16)
                hud.detailsLabel.numberOfLines = 0
                hud.detailsLabel.textColor = UIColor.white
                
                // User defined the hud configuration.
                self.options.hudCallback?(hud)
                return hud
            })
            vc.key = self.key
            vc.show()
        }
    }
}
