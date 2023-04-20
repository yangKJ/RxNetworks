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
import Toast_Swift

/// 自动提示插件，基于Toast封装
/// Warning plugin, based on Toast package
public final class NetworkWarningPlugin {
    
    public let options: Options
    
    public init(options: Options = .keyWindow) {
        self.options = options
    }
    
    public convenience init(in window: Bool = true,
                            duration: TimeInterval = 1,
                            cover: Bool = true,
                            position: ToastPosition = .bottom,
                            toastStyle: ToastStyle? = nil) {
        let dp = window ? DisplayPosition.keyWindow : DisplayPosition.topView
        let options = Options(in: dp, duration: duration, cover: cover, position: position, toastStyle: toastStyle)
        self.init(options: options)
    }
}

extension NetworkWarningPlugin {
    public struct Options {
        /// Display in the window position.
        public static let keyWindow: Options = .init(in: .keyWindow)
        
        /// Sets the default position. Used for the `makeToast` and `showToast` methods that don't require an explicit position.
        let position: ToastPosition
        /// The default duration. Used for the `makeToast` and `showToast` methods that don't require an explicit duration.
        let duration: TimeInterval
        /// Display super view.
        let displayView: UIView?
        
        /// 是否会覆盖上次的错误展示，如果上次错误展示还在，新的错误展示是否需要覆盖上次。
        /// Whether it will overwrite the last error display,
        /// If the last error display is still there, whether the new error display needs to overwrite the last one.
        let coverLastToast: Bool
        
        let toastStyle: ToastStyle?
        
        public init(in type: DisplayPosition = .keyWindow,
                    duration: TimeInterval = 1.0,
                    cover: Bool = true,
                    position: ToastPosition = .bottom,
                    toastStyle: ToastStyle? = nil) {
            self.position = position
            self.displayView = type.displayView
            self.duration = duration
            self.coverLastToast = cover
            self.toastStyle = toastStyle
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
        DispatchQueue.main.async {
            guard let view = self.options.displayView else {
                return
            }
            if self.options.coverLastToast {
                view.hideToast()
            }
            
            let style = self.options.toastStyle ?? {
                var style = ToastStyle()
                style.messageColor = UIColor.white
                return style
            }()
            
            view.makeToast(text, duration: self.options.duration, position: self.options.position, style: style)
            
            // or perhaps you want to use this style for all toasts going forward?
            // just set the shared style and there's no need to provide the style again
            ToastManager.shared.style = style
            
            // toggle "tap to dismiss" functionality
            ToastManager.shared.isTapToDismissEnabled = true
            
            // toggle queueing behavior
            ToastManager.shared.isQueueEnabled = !self.options.coverLastToast
        }
    }
}
