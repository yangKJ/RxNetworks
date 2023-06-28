//
//  AnimatedLoadingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import Moya

/// 动画加载插件，基于Lottie封装
/// Animation loading plug-in, based on Lottie package.
public struct AnimatedLoadingPlugin {
    let queue = DispatchQueue(label: "condy.animted.loading.network.queue", attributes: .concurrent)
    
    public let options: Options
    
    public init(options: Options = Options.inTopView) {
        self.options = options
    }
    
    /// Hide the loading hud.
    public func hideLoadingHUD() {
        AnimatedLoadingPlugin.hideLoadingHUD(view: self.options.displayView)
    }
    
    /// 如果设置过`autoHideLoading`请记得自己来关闭加载动画，倘若失败插件会帮你关闭，倘若均成功请自己来关闭
    /// If you have set `autoHideLoading = false`, please remember to close the loading animation yourself.
    /// If it fails, the plug-in will help you close it. If it is successful, please close it yourself.
    public static func hideLoadingHUD(view: UIView?) {
        DispatchQueue.main.async {
            if let view = view {
                view.hideBackView()
                view.hideHUD()
                return
            }
            [true, false].forEach {
                let view = DisplayPosition.keyWindowOrTopView($0)
                view?.hideBackView()
                view?.hideHUD()
            }
        }
    }
}

extension AnimatedLoadingPlugin {
    public struct Options {
        /// Displayed in the current view.
        public static let inTopView = Options.init(in: .topView)
        
        /// Loading will not be automatically hidden and display window.
        public static let dontAutoHide: Options = .init(autoHide: false)
        
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        /// Loading display super view.
        let displayView: UIView?
        
        /// 是否需要自动隐藏Loading，可用于链式请求时刻，最开始的网络请求开启Loading，最末尾网络请求结束再移除Loading。
        ///
        /// 如果设置过`autoHideLoading = false`请记得自己来关闭加载动画，倘若失败插件会帮你关闭，倘若均成功请自己来关闭。
        /// 参考用法：https://github.com/yangKJ/RxNetworks/blob/master/RxNetworks/Modules/AnimatedLoading/AnimatedLoadingViewModel.swift
        ///
        ///     if let plugin = loadingApi.givenPlugin(type: AnimatedLoadingPlugin.self) {
        ///         plugin.hideLoadingHUD()
        ///     }
        ///
        ///     or
        ///
        ///     AnimatedLoadingPlugin.hideLoadingHUD(view: nil)
        ///
        /// Whether you need to automatically hide Loading, it can be used for chain request.
        /// The first network request starts loading, and the last network request ends and then remove the loading hud.
        public let autoHideLoading: Bool
        
        /// Set up this loading animated JSON file named.
        let animatedJSON: String?
        
        public init(text: String = "正在加载...",
                    in type: DisplayPosition = .topView,
                    delay: Double = 0.0,
                    autoHide: Bool = true,
                    animatedJSON: String? = nil) {
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.displayView = type.displayView
            self.animatedJSON = animatedJSON
            self.autoHideLoading = autoHide
        }
    }
}

extension AnimatedLoadingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "AnimatedLoading"
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            if let view = self.options.displayView {
                view.showHudBackView()
                let animatedNamed = self.options.animatedJSON ?? NetworkConfig.animatedJSON
                view.showLoadingHUD(animatedNamed)
                view.animatedLoadingHud?.textLabel.text = self.options.displayLoadText
            }
        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if options.autoHideLoading == false, case .success = result {
            return
        }
        self.queue.asyncAfter(deadline: .now() + options.delayHideHUD) {
            self.hideLoadingHUD()
        }
    }
}
