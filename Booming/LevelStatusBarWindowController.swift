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
    func makeOpenedStatusConstraint(superview: ViewType)
    
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
open class LevelStatusBarWindowController: ViewControllerType {
    private static let window: WindowType = X.createWindow()
    private static var lastKeyWindow: WindowType?
    private static var controllers = [LevelStatusBarWindowController]()
    
    private var isCalledClose = false
    private var canNotBeCanceled = false
    private lazy var loadingCount: Int = 0
    private lazy var lock = NSLock()
    
    #if os(macOS)
    private let windowController = NSWindowController()
    #else
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
    #endif
    
    private lazy var overlay: ViewType = {
        let view = ViewType(frame: self.view.bounds)
        view.backgroundColor = overlayBackgroundColor
        #if os(macOS)
        let click = NSClickGestureRecognizer(target: self, action: #selector(overlayTap))
        view.addGestureRecognizer(click)
        #else
        let gesture = UITapGestureRecognizer(target: self, action: #selector(overlayTap))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
        #endif
        return view
    }()
    
    public var key: String?
    
    public var showUpView: LevelStatusBarWindowShowUpable?
    
    /// 点击外面区域是否可关闭
    public var canCloseWhenTapOutSize: Bool = true
    
    /// 外界已经将`showUpView`添加到控制器
    public var addedShowUpView: Bool = false
    
    public var overlayBackgroundColor: ColorType = .black.withAlphaComponent(0.2) {
        didSet {
            self.overlay.backgroundColor = overlayBackgroundColor
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        #if os(macOS)
        self.overlay.wantsLayer = true
        #endif
        self.view.addSubview(self.overlay)
        if self.addedShowUpView {
            if let alertView = self.showUpView as? ViewType {
                #if os(iOS) || os(tvOS)
                self.view.bringSubviewToFront(alertView)
                #endif
            }
        } else if let alertView = self.showUpView as? ViewType {
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
        #if os(macOS)
        Self.window.isHidden = false
        Self.window.contentViewController = self
        windowController.contentViewController = Self.window.contentViewController
        windowController.window = Self.window
        windowController.showWindow(self)
        #else
        Self.window.isHidden = false
        Self.window.windowLevel = UIWindow.Level.statusBar
        Self.window.rootViewController = self
        Self.window.makeKeyAndVisible()
        #endif
        
        self.setupOverlayHidden(hide: true)
        self.showUpView?.show(animated: true, animation: { [weak self] in
            self?.setupOverlayHidden(hide: false)
            self?.overlay.backgroundColor = self?.overlayBackgroundColor
        }, completion: completion)
    }
    
    public func close(animated: Bool = true) {
        self.isCalledClose = true
        self.showUpView?.close(animated: animated, animation: { [weak self] in
            self?.setupOverlayHidden(hide: true)
        }, completion: self.closeCompleted)
    }
    
    private func closeCompleted(_: Bool) {
        guard Self.window.rootViewController == self else {
            return
        }
        if let window_ = Self.lastKeyWindow {
            if window_.rootViewController != nil {
                #if os(macOS)
                windowController.contentViewController = window_.contentViewController
                windowController.window = window_
                windowController.showWindow(self)
                #else
                window_.makeKeyAndVisible()
                #endif
            }
            Self.lastKeyWindow = nil
        } else if let window_ = X.window() {
            #if os(macOS)
            windowController.contentViewController = window_.contentViewController
            windowController.window = window_
            windowController.showWindow(self)
            #else
            window_.makeKeyAndVisible()
            #endif
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
    
    private func setupOverlayHidden(hide: Bool) {
        #if os(macOS)
        self.overlay.isHidden = hide
        #else
        self.overlay.alpha = hide ? 0 : 1
        #endif
    }
    
    public static func cancelAllBackgroundControllersShow() {
        Self.controllers = Self.controllers.filter({ $0.canNotBeCanceled })
    }
    
    public static func forceCancelAllControllers() {
        if let controller = Self.window.rootViewController as? LevelStatusBarWindowController, !controller.canNotBeCanceled {
            Self.window.rootViewController = nil
            Self.window.isHidden = true
        }
        cancelAllBackgroundControllersShow()
    }
}
