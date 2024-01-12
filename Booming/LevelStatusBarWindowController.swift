//
//  Self.swift
//  RxNetworks
//
//  Created by Condy on 2023/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation

public protocol LevelStatusBarWindowShowUpable {
    /// 打开状态
    /// - Parameter superview: 父视图
    func makeOpenedStatusConstraint(superview: BOOMINGView)
    
    /// 根据添加设置内容，刷新界面
    func refreshBeforeShow()
    
    /// 显示
    /// - Parameters:
    ///   - animated: 是否动画效果
    ///   - animation: 动画内容
    ///   - completion: 完成回调
    func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    /// 关闭
    /// - Parameters:
    ///   - animated: 是否动画效果
    ///   - animation: 动画内容
    ///   - completion: 完成回调
    func close(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
}

/// 状态窗口显示器
open class LevelStatusBarWindowController: BOOMINGViewController {
    private var isCalledClose = false
    private var canNotBeCanceled = false
    private var loadingCount: Int = 0
    private lazy var lock = NSLock()
    
    private lazy var overlay: BOOMINGView = {
        let view = BOOMINGView(frame: self.view.bounds)
//        view.backgroundColor = overlayBackgroundColor
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlayTap)))
//        view.isUserInteractionEnabled = true
        return view
    }()
    
    public var key: String?
    
    public var showUpView: LevelStatusBarWindowShowUpable?
    
    /// 点击外面区域是否可关闭
    public var canCloseWhenTapOutSize: Bool = true
    
    /// 外界已经将`showUpView`添加到控制器
    public var addedShowUpView: Bool = false
    
    public var overlayBackgroundColor: BOOMINGColor = .black.withAlphaComponent(0.2) {
        didSet {
            //self.overlay.backgroundColor = overlayBackgroundColor
        }
    }
    
    public func addedLoadingCount() {
        self.lock.lock()
        self.loadingCount += 1
        self.lock.unlock()
    }
    
    public func subtractLoadingCount() -> Int {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.loadingCount -= 1
        return self.loadingCount
    }
    
    private var overlayTapCloseBlock: ((LevelStatusBarWindowController) -> Void)?
    public func setOverlayTapCloseBlock(block: @escaping (LevelStatusBarWindowController) -> Void) {
        self.overlayTapCloseBlock = block
    }
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    open override var prefersStatusBarHidden: Bool {
        if let controller = X.topViewController() {
            return controller.prefersStatusBarHidden
        }
        return true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let controller = X.topViewController() {
            return controller.preferredStatusBarStyle
        }
        return .default
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(self.overlay)
        if self.addedShowUpView {
            if let alertView = self.showUpView as? UIView {
                self.view.bringSubviewToFront(alertView)
            }
        } else if let alertView = self.showUpView as? UIView {
            self.view.addSubview(alertView)
        }
        self.showUpView?.makeOpenedStatusConstraint(superview: self.view)
    }
    
    public func show(completion: ((Bool) -> Void)? = nil) {
        Self.controllers.removeAll { $0 == self }
        if let rootViewController = Self.window.rootViewController as? Self, !rootViewController.isCalledClose {
            Self.controllers.append(rootViewController)
            Self.window.rootViewController = nil
        }
        self.showUpView?.refreshBeforeShow()
        if Self.lastKeyWindow != Self.window {
            Self.lastKeyWindow = X.keyWindow()
        }
        Self.window.isHidden = false
        Self.window.windowLevel = UIWindow.Level.statusBar
        Self.window.rootViewController = self
        Self.window.makeKeyAndVisible()
        
        self.overlay.alpha = 0
        self.showUpView?.show(animated: true, animation: { [weak self] in
            self?.overlay.alpha = 1.0
            self?.overlay.backgroundColor = self?.overlayBackgroundColor
        }, completion: completion)
    }
    
    public func close(animated: Bool = true) {
        self.isCalledClose = true
        self.showUpView?.close(animated: animated, animation: { [weak self] in
            self?.overlay.alpha = 0
        }, completion: self.closeCompleted)
    }
    
    private func closeCompleted(_: Bool) {
        guard Self.window.rootViewController == self else {
            return
        }
        if let lastKeyWindow = Self.lastKeyWindow {
            if lastKeyWindow.rootViewController != nil {
                lastKeyWindow.makeKeyAndVisible()
            }
            Self.lastKeyWindow = nil
        } else if let window = UIApplication.shared.delegate?.window, window != nil {
            window?.makeKeyAndVisible()
        }
        Self.window.rootViewController = nil
        Self.window.isHidden = true
        if Self.controllers.count < 10 {
            while let rootViewController = Self.controllers.last {
                if rootViewController.isCalledClose {
                    Self.controllers.removeLast()
                    continue
                }
                rootViewController.show()
                break
            }
        } else {
            Self.controllers.removeAll()
        }
    }
    
    @objc private func overlayTap() {
        if canCloseWhenTapOutSize {
            close()
            overlayTapCloseBlock?(self)
        }
    }
    #else
    public func close(animated: Bool = true) {
        self.isCalledClose = true
        self.showUpView?.close(animated: animated, animation: { [weak self] in
            //self?.overlay.alpha = 0
        }, completion: self.closeCompleted)
    }
    
    private func closeCompleted(_: Bool) {
        
    }
    #endif
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension LevelStatusBarWindowController {
    private static let window = UIWindow(frame: UIScreen.main.bounds)
    private static var lastKeyWindow: UIWindow?
    private static var controllers = [LevelStatusBarWindowController]()
    
    public static func cancelAllBackgroundControllersShow() {
        Self.controllers = Self.controllers.filter({ $0.canNotBeCanceled })
    }
    
    public static func forcecancelAllControllers() {
        if let controller = Self.window.rootViewController as? LevelStatusBarWindowController, !controller.canNotBeCanceled {
            Self.window.rootViewController = nil
            Self.window.isHidden = true
        }
        cancelAllBackgroundControllersShow()
    }
}
#endif
