//
//  Self.swift
//  RxNetworks
//
//  Created by Condy on 2023/10/5.
//  https://github.com/yangKJ/RxNetworks

import Foundation

public protocol LevelStatusBarWindowShowUpable {
    
    func makeOpenedStatusConstraint(superview: ViewType)
    
    func show(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    func close(animated: Bool, animation: (() -> Void)?, completion: ((Bool) -> Void)?)
    
    /// Refresh the interface according to the added settings.
    func refreshBeforeShow()
    /// Click on the outside area to close it.
    var canCloseWhenTapOutSize: Bool { get }
}

/// 状态窗口显示器
open class LevelStatusBarWindowController: ViewControllerType {
    private static let window: WindowType = X.createWindow()
    private static var lastKeyWindow: WindowType?
    private static var controllers = [LevelStatusBarWindowController]()
    
    private var isCalledClose = false
    private var canNotBeCanceled = false
    
    #if os(macOS)
    private let windowController = NSWindowController()
    #else
    open override var prefersStatusBarHidden: Bool {
        if let controller = self.topViewController() {
            return controller.prefersStatusBarHidden
        }
        return true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let controller = self.topViewController() {
            return controller.preferredStatusBarStyle
        }
        return .default
    }
    #endif
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initShowUpViewIfNeed()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initShowUpViewIfNeed()
    }
    
    open func initShowUpViewIfNeed() {
        
    }
    
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
    
    /// The outside world has added `showUpView` to the controller.
    public var addedShowUpView: Bool = false
    
    public var overlayBackgroundColor: ColorType = .black.withAlphaComponent(0.2) {
        didSet {
            self.overlay.backgroundColor = overlayBackgroundColor
        }
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
            if let containerView = self.showUpView as? ViewType {
                #if os(iOS) || os(tvOS)
                self.view.bringSubviewToFront(containerView)
                #endif
            }
        } else if let containerView = self.showUpView as? ViewType {
            self.view.addSubview(containerView)
        }
        self.showUpView?.makeOpenedStatusConstraint(superview: self.view)
    }
    
    public func show(completion: ((Bool) -> Void)? = nil) {
        Self.controllers.removeAll { $0 == self }
        if let rootViewController = Self.window.rootViewController as? Self, !rootViewController.isCalledClose {
            LevelStatusBarWindowController.controllers.append(rootViewController)
            LevelStatusBarWindowController.window.rootViewController = nil
        }
        self.showUpView?.refreshBeforeShow()
        if LevelStatusBarWindowController.lastKeyWindow != LevelStatusBarWindowController.window {
            LevelStatusBarWindowController.lastKeyWindow = X.keyWindow()
        }
        #if os(macOS)
        LevelStatusBarWindowController.window.isHidden = false
        LevelStatusBarWindowController.window.contentViewController = self
        windowController.contentViewController = LevelStatusBarWindowController.window.contentViewController
        windowController.window = LevelStatusBarWindowController.window
        windowController.showWindow(self)
        #else
        LevelStatusBarWindowController.window.isHidden = false
        LevelStatusBarWindowController.window.windowLevel = UIWindow.Level.statusBar
        LevelStatusBarWindowController.window.rootViewController = self
        LevelStatusBarWindowController.window.makeKeyAndVisible()
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
        guard LevelStatusBarWindowController.window.rootViewController == self else {
            return
        }
        LevelStatusBarWindowController.window.isHidden = true
        if let lastKeyWindow = LevelStatusBarWindowController.lastKeyWindow {
            if lastKeyWindow.rootViewController != nil {
                #if os(macOS)
                windowController.contentViewController = lastKeyWindow.contentViewController
                windowController.window = lastKeyWindow
                windowController.showWindow(self)
                #else
                lastKeyWindow.makeKeyAndVisible()
                #endif
            }
            LevelStatusBarWindowController.lastKeyWindow = nil
        } else if let mainWindow = mainWindow {
            #if os(macOS)
            windowController.contentViewController = mainWindow.contentViewController
            windowController.window = mainWindow
            windowController.showWindow(self)
            #else
            mainWindow.makeKeyAndVisible()
            #endif
        }
        LevelStatusBarWindowController.window.rootViewController = nil
        LevelStatusBarWindowController.window.isHidden = true
        if Self.controllers.count < 10 {
            while let rootViewController = LevelStatusBarWindowController.controllers.last {
                if rootViewController.isCalledClose {
                    LevelStatusBarWindowController.controllers.removeLast()
                    continue
                }
                rootViewController.show()
                break
            }
        } else {
            LevelStatusBarWindowController.controllers.removeAll()
        }
    }
    
    private var mainWindow: WindowType? {
        #if os(macOS)
        return NSApplication.shared.mainWindow
        #else
        return UIApplication.shared.delegate?.window ?? nil
        #endif
    }
    
    @objc private func overlayTap() {
        if self.showUpView?.canCloseWhenTapOutSize ?? false {
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
        LevelStatusBarWindowController.controllers = LevelStatusBarWindowController.controllers.filter({ $0.canNotBeCanceled })
    }
    
    public static func forceCancelAllControllers() {
        if let controller = Self.window.rootViewController as? LevelStatusBarWindowController, !controller.canNotBeCanceled {
            LevelStatusBarWindowController.window.rootViewController = nil
            LevelStatusBarWindowController.window.isHidden = true
        }
        cancelAllBackgroundControllersShow()
    }
    
    #if canImport(UIKit)
    private func topViewController() -> UIViewController? {
        let window = UIApplication.shared.delegate?.window
        guard window != nil, let rootViewController = window?!.rootViewController else {
            return nil
        }
        return self.getTopViewController(controller: rootViewController)
    }
    
    private func getTopViewController(controller: UIViewController) -> UIViewController {
        if let presentedViewController = controller.presentedViewController {
            return self.getTopViewController(controller: presentedViewController)
        } else if let navigationController = controller as? UINavigationController {
            if let topViewController = navigationController.topViewController {
                return self.getTopViewController(controller: topViewController)
            }
            return navigationController
        } else if let tabbarController = controller as? UITabBarController {
            if let selectedViewController = tabbarController.selectedViewController {
                return self.getTopViewController(controller: selectedViewController)
            }
            return tabbarController
        } else {
            return controller
        }
    }
    #endif
}

extension LevelStatusBarWindowShowUpable {
    public func makeOpenedStatusConstraint(superview: ViewType) { }
    public func refreshBeforeShow() { }
    public var canCloseWhenTapOutSize: Bool { false }
}
