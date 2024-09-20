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
import Booming

/// 动画加载插件，基于Lottie封装
/// Animation loading plugin, based on Lottie package.
public struct AnimatedLoadingPlugin: HasKeyAndDelayPropertyProtocol {
    
    public var key: String?
    
    public var delay: Double {
        options.delayHideHUD
    }
    
    public let options: AnimatedLoadingPlugin.Options
    
    public init(options: AnimatedLoadingPlugin.Options = .loading) {
        self.options = options
    }
    
    /// Hide the loading hud.
    public func hideLoadingHUD() {
        let vc = HUDs.removeHUD(key: key)
        vc?.close()
    }
}

extension AnimatedLoadingPlugin {
    public struct Options {
        /// Only lottie hud display loading hud view controller.
        public static let `default` = Options.init(text: "")
        /// Default text hud display loading hud view controller.
        public static let loading = Options.init(text: "正在加载...")
        /// Loading will not be automatically hidden and display loading hud view controller.
        public static let dontAutoHide = {
            var opt = Options.init(text: "")
            opt.autoHideLoading = false
            return opt
        }()
        
        /// Do you need to automatically hide the loading hud.
        public var autoHideLoading: Bool = true
        /// A subdirectory in the bundle in which the animation is located. Optional.
        public var subdirectory: String?
        /// Set the window background color.
        public var overlayBackgroundColor: ColorType = .black.withAlphaComponent(0.2)
        /// Set the HUD background.
        public var hudBackground: ColorType = .black.withAlphaComponent(0.7)
        /// Set the size of HUD rounded corners.
        public var hudCornerRadius: CGFloat = 15.0
        
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        /// Set up this loading animated JSON file named.
        let animatedJSON: String?
        /// The bundle in which the animation is located. Defaults to `Bundle.main`.
        let bundle: Bundle
        
        public init(text: String = "", delay: Double = 0.0, animatedJSON: String? = nil, bundle: Bundle = .main) {
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.animatedJSON = animatedJSON
            self.bundle = bundle
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
    
    public func outputResult(_ result: OutputResult, target: any TargetType, onNext: @escaping OutputResultBlock) {
        if (hudViewController?.subtractLoadingCount() ?? 0) <= 0, options.autoHideLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + options.delayHideHUD) {
                if let hud = hudViewController, hud.canRemoveThisHud {
                    self.hideLoadingHUD()
                }
            }
        }
        onNext(result)
    }
}

extension AnimatedLoadingPlugin {
    
    private var hudViewController: LoadingHudViewController? {
        HUDs.readHUD(suffix: pluginName).first as? LoadingHudViewController
    }
    
    private func showHUD() {
        if let vc = hudViewController {
            setupHUD(hud: (vc.showUpView as? AnimatedLoadingHUD))
            vc.overlayBackgroundColor = options.overlayBackgroundColor
            vc.addedLoadingCount()
        } else {
            let animatedNamed = self.options.animatedJSON ?? BoomingSetup.animatedJSON
            let vc = LoadingHudViewController(createShowUpViewCallback: {
                AnimatedLoadingHUD(animatedNamed: animatedNamed, bundle: options.bundle, subdirectory: options.subdirectory)
            })
            setupHUD(hud: (vc.showUpView as? AnimatedLoadingHUD))
            vc.overlayBackgroundColor = options.overlayBackgroundColor
            vc.key = self.key
            vc.show()
        }
    }
    
    private func setupHUD(hud: AnimatedLoadingHUD?) {
        hud?.containerView.backgroundColor = options.hudBackground
        hud?.cornerRadius = options.hudCornerRadius
        hud?.setupLoadingText(options.displayLoadText)
    }
}
