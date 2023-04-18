//
//  UIView+Loading.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import ObjectiveC


extension UIView {
    private struct AnimatedLoadingExtensionKey {
        static var loadingHud: Void?
    }
    
    private var animatedLoadingHud: LoadingHud? {
        set {
            objc_setAssociatedObject(self, &AnimatedLoadingExtensionKey.loadingHud, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AnimatedLoadingExtensionKey.loadingHud) as? LoadingHud
        }
    }
    
    @discardableResult func showLoadingHUD(_ animatedNamed: String?) -> LoadingHud {
        if self.animatedLoadingHud != nil {
            return self.animatedLoadingHud!
        }
        self.hideHUD()
        self.animatedLoadingHud = LoadingHud(frame: .zero, animatedNamed: animatedNamed)
        self.animatedLoadingHud?.show(in: self)
        return self.animatedLoadingHud!
    }
    
    func hideHUD() {
        self.animatedLoadingHud?.hide()
        self.animatedLoadingHud = nil
    }
}
