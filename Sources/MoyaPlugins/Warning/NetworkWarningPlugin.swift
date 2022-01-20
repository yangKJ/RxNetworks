//
//  NetworkWarningPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//

///`Toast_Swift`文档
/// https://github.com/scalessec/Toast-Swift

import Foundation
import Moya
import Toast_Swift

/// 自动提示插件，基于Toast封装
/// Warning plugin, based on Toast package
public final class NetworkWarningPlugin {
    
    /// Sets the default position. Used for the `makeToast` and `showToast` methods that don't require an explicit position.
    let position: ToastPosition
    /// Whether to display the Window again, the default is YES
    let displayInWindow: Bool
    /// The default duration. Used for the `makeToast` and `showToast` methods that don't require an explicit duration.
    let duration: TimeInterval
    
    /// 是否会覆盖上次的错误展示，
    /// 如果上次错误展示还在，新的错误展示是否需要覆盖上次
    /// Whether it will overwrite the last error display,
    /// If the last error display is still there, whether the new error display needs to overwrite the last one
    let coverLastToast: Bool
    
    public private(set) var toastStyle: ToastStyle? = nil
    
    public init(in window: Bool = true,
                duration: TimeInterval = 1,
                cover: Bool = true,
                position: ToastPosition = .bottom,
                toastStyle: ToastStyle? = nil) {
        self.position = position
        self.displayInWindow = window
        self.duration = duration
        self.coverLastToast = cover
        self.toastStyle = toastStyle
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
            
            if self.coverLastToast {
                view.hideToast()
            }
            
            var style = self.toastStyle
            if style == nil {
                style = ToastStyle()
                style!.messageColor = UIColor.white
            }
            
            view.makeToast(text, duration: self.duration, position: self.position, style: style!)

            // or perhaps you want to use this style for all toasts going forward?
            // just set the shared style and there's no need to provide the style again
            ToastManager.shared.style = style!
            
            // toggle "tap to dismiss" functionality
            ToastManager.shared.isTapToDismissEnabled = true

            // toggle queueing behavior
            ToastManager.shared.isQueueEnabled = !self.coverLastToast
        }
    }
}
