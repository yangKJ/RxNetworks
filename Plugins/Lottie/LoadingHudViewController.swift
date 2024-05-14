//
//  LoadingHudViewController.swift
//  Booming
//
//  Created by Condy on 2024/4/20.
//

import Foundation

class LoadingHudViewController: LevelStatusBarWindowController {
    
    private lazy var loadingCount: Int = 0
    private lazy var lock = NSLock()
    
    init(animatedNamed: String?, bundle: Bundle, subdirectory: String?) {
        super.init(nibName: nil, bundle: nil)
        self.showUpView = LoadingHud(frame: .zero, animatedNamed: animatedNamed, bundle: bundle, subdirectory: subdirectory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLoadingText(_ text: String?) {
        (showUpView as? LoadingHud)?.setupLoadingText(text)
    }
    
    override func show(completion: ((Bool) -> Void)? = nil) {
        super.show(completion: completion)
        self.addedLoadingCount()
        if let key = key {
            X.saveHUD(key: key, viewController: self)
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
