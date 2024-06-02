//
//  LoadingHudViewController.swift
//  Booming
//
//  Created by Condy on 2024/4/20.
//  https://github.com/yangKJ/RxNetworks

import Foundation

public final class LoadingHudViewController: LevelStatusBarWindowController {
    
    private lazy var loadingCount: Int = 0
    private lazy var lock = NSLock()
    
    public init(createShowUpViewCallback: @escaping () -> LevelStatusBarWindowShowUpable) {
        super.init(nibName: nil, bundle: nil)
        self.showUpView = createShowUpViewCallback()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func show(completion: ((Bool) -> Void)? = nil) {
        super.show(completion: completion)
        self.addedLoadingCount()
        if let key = key {
            HUDs.saveHUD(key: key, viewController: self)
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
}
