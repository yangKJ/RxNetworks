//
//  AnimatedLoadingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

///`Lottie`文档
/// https://github.com/airbnb/lottie-ios

import Foundation
import Moya

/// 动画加载插件，基于Lottie封装
/// Animation loading plugin, based on Lottie package.
public struct AnimatedLoadingPlugin: PluginPropertiesable {
    
    public var plugins: APIPlugins = []
    
    public var key: String?
    
    public var delay: Double {
        options.delayHideHUD
    }
    
    public let options: Options
    
    public init(options: Options = .`default`) {
        self.options = options
    }
    
    /// Hide the loading hud.
    public func hideLoadingHUD() {
        let vc = X.removeHUD(key: key)
        vc?.close()
    }
}

extension AnimatedLoadingPlugin {
    public struct Options {
        /// Loading will not be automatically hidden and display window.
        public static let `default`: Options = .init(text: "")
        
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        /// Set up this loading animated JSON file named.
        let animatedJSON: String?
        
        public init(text: String = "正在加载...", delay: Double = 0.0, animatedJSON: String? = nil) {
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.animatedJSON = animatedJSON
        }
    }
}

extension AnimatedLoadingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "AnimatedLoading"
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            showHUD()
        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        guard let key = self.key, let vc = X.readHUD(key: key) as? LoadingHudViewController else {
            return
        }
        if vc.subtractLoadingCount() <= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + options.delayHideHUD) {
                self.hideLoadingHUD()
            }
        }
    }
}

extension AnimatedLoadingPlugin {
    
    private func showHUD() {
        guard let key = self.key else {
            return
        }
        if let vc = X.readHUD(key: key) as? LoadingHudViewController {
            vc.addedLoadingCount()
        } else {
            let animatedNamed = self.options.animatedJSON ?? BoomingSetup.animatedJSON
            let vc = LoadingHudViewController(animatedNamed: animatedNamed)
            vc.setupLoadingText(self.options.displayLoadText)
            vc.key = key
            vc.show()
        }
    }
}
