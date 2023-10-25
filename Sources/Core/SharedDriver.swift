//
//  SharedDriver.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//

import Foundation
import Moya

/// 共享网络中转数据
struct SharedDriver {
    typealias Key = String
    
    static var shared = SharedDriver()
    
    private let lock = NSLock()
    private let tasklock = NSLock()
    private let HUDLock = NSLock()
    
    private var requestingAPIs = [Key: (api: NetworkAPI, plugins: APIPlugins)]()
    private var tasks = [Key: Moya.Cancellable]()
    
    private var cacheBlocks = [(key: Key, success: APISuccess, failure: APIFailure)]()
    
    private var cacheHUDs = [Key: LevelStatusBarWindowController]()
}

// MARK: - api
extension SharedDriver {
    
    func readRequestAPI(_ key: Key) -> NetworkAPI? {
        self.lock.lock()
        defer { lock.unlock() }
        return self.requestingAPIs[key]?.api
    }
    
    func readRequestPlugins(_ key: Key) -> APIPlugins {
        self.lock.lock()
        defer { lock.unlock() }
        return self.requestingAPIs[key]?.plugins ?? []
    }
    
    mutating func removeRequestingAPI(_ key: Key) {
        self.lock.lock()
        let plugins = self.requestingAPIs[key]?.plugins
        self.requestingAPIs.removeValue(forKey: key)
        // 没有正在请求的网络，则移除全部加载Loading
        if NetworkConfig.lastCompleteAndCloseLoadingHUDs, self.requestingAPIs.isEmpty, let p = plugins {
            let maxTime = X.maxDelayTime(with: p)
            DispatchQueue.main.asyncAfter(deadline: .now() + maxTime) {
                SharedDriver.shared.removeLoadingHUDs()
            }
        }
        self.lock.unlock()
    }
    
    mutating func addedRequestingAPI(_ api: NetworkAPI, key: Key, plugins: APIPlugins) {
        self.lock.lock()
        self.requestingAPIs[key] = (api, plugins)
        self.lock.unlock()
    }
}

// MARK: - task and blocks
extension SharedDriver {
    
    func readTask(key: Key) -> Cancellable? {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        return self.tasks[key]
    }
    
    mutating func cacheBlocks(key: Key, success: @escaping APISuccess, failure: @escaping APIFailure) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.cacheBlocks.append((key, success, failure))
    }
    
    mutating func cacheTask(key: Key, task: Cancellable) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.tasks[key] = task
    }
    
    mutating func result(_ type: Result<APISuccessJSON, APIFailureError>, key: Key) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        switch type {
        case .success(let json):
            self.cacheBlocks.forEach {
                $0.key == key ? $0.success(json) : nil
            }
        case .failure(let error):
            self.cacheBlocks.forEach {
                $0.key == key ? $0.failure(error) : nil
            }
        }
        self.tasks.removeValue(forKey: key)
        self.cacheBlocks.removeAll { $0.key == key }
    }
}

// MARK: - hud
extension SharedDriver {
    
    func readHUD(key: String) -> LevelStatusBarWindowController? {
        self.HUDLock.lock()
        defer { HUDLock.unlock() }
        return self.cacheHUDs[key]
    }
    
    func readHUD(prefix: String) -> [LevelStatusBarWindowController] {
        self.HUDLock.lock()
        defer { HUDLock.unlock() }
        return self.cacheHUDs.compactMap {
            if let prefix_ = $0.key.components(separatedBy: "_").first, prefix_ == prefix {
                return $0.value
            }
            return nil
        }
    }
    
    func readHUD(suffix: String) -> [LevelStatusBarWindowController] {
        self.HUDLock.lock()
        defer { HUDLock.unlock() }
        return self.cacheHUDs.compactMap {
            if let suffix_ = $0.key.components(separatedBy: "_").last, suffix_ == suffix {
                return $0.value
            }
            return nil
        }
    }
    
    mutating func saveHUD(key: Key, window: LevelStatusBarWindowController) {
        self.HUDLock.lock()
        self.cacheHUDs[key] = window
        self.HUDLock.unlock()
    }
    
    @discardableResult mutating func removeHUD(key: Key?) -> LevelStatusBarWindowController? {
        guard let key = key else {
            return nil
        }
        self.HUDLock.lock()
        let window = self.cacheHUDs[key]
        self.cacheHUDs.removeValue(forKey: key)
        self.HUDLock.unlock()
        return window
    }
    
    mutating func removeAllAtLevelStatusBarWindow() {
        self.HUDLock.lock()
        self.cacheHUDs.forEach {
            $0.value.close()
        }
        self.cacheHUDs.removeAll()
        self.HUDLock.unlock()
    }
    
    mutating func removeLoadingHUDs() {
        self.HUDLock.lock()
        for (key, hud) in self.cacheHUDs where X.loadingSuffix(key: key) {
            self.cacheHUDs.removeValue(forKey: key)
            hud.close()
        }
        self.HUDLock.unlock()
    }
}
