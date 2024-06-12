//
//  MBProgressHUD+Ext.swift
//  RxNetworks
//
//  Created by Condy on 2023/10/6.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Booming

#if canImport(MBProgressHUD)

import MBProgressHUD

extension MBProgressHUD: LevelStatusBarWindowShowUpable {
    
    public func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            self.show(animated: animated)
            if animated {
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
            } else {
                animation?()
                completion?(true)
            }
        }
    }
    
    public func close(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            self.hide(animated: animated)
            if animated {
                UIView.animate(withDuration: 0.2, animations: {
                    animation?()
                }, completion: completion)
            } else {
                animation?()
                completion?(true)
            }
        }
    }
}

#endif
