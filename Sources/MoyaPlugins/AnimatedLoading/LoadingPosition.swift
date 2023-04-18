//
//  LoadingPosition.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation

/// 动画加载框展示位置
/// Loading box display position.
public enum LoadingPosition {
    case view(UIView)
    case topView
    case keyWindow
    
    var displayView: UIView? {
        switch self {
        case .view(let uIView):
            return uIView
        case .topView:
            return RxNetworks.X.View.topViewController?.view
        case .keyWindow:
            return RxNetworks.X.View.keyWindow
        }
    }
}
