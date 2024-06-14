//
//  Shared.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 共享网络中转数据
struct Shared {
    typealias Key = String
    
    static var shared = Shared()
    
    private let lock = NSLock()
    private let tasklock = NSLock()
    
    private var requestingAPIs = [Key: (api: NetworkAPI, plugins: APIPlugins)]()
    private var tasks = [Key: Moya.Cancellable]()
    
    private var cacheBlocks = [(key: Key, successed: APISuccessed, failed: APIFailure)]()
}

// MARK: - api
extension Shared {
    
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
        // 延迟一点点时间移除，解决串行网络中间闪一下问题
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Shared.shared.lock.lock()
            let plugins = Shared.shared.requestingAPIs[key]?.plugins
            Shared.shared.requestingAPIs.removeValue(forKey: key)
            Shared.shared.lock.unlock()
            // 没有正在请求的网络，则移除全部加载Loading
            if BoomingSetup.lastCompleteAndCloseLoadingHUDs, Shared.shared.requestingAPIs.isEmpty {
                HUDs.delayRemoveLoadingHUDs(with: plugins)
            }
        }
    }
    
    mutating func addedRequestingAPI(_ api: NetworkAPI, key: Key, plugins: APIPlugins) {
        self.lock.lock()
        self.requestingAPIs[key] = (api, plugins)
        self.lock.unlock()
    }
}

// MARK: - task and blocks
extension Shared {
    
    func readTask(key: Key) -> Moya.Cancellable? {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        return self.tasks[key]
    }
    
    mutating func cacheBlocks(key: Key, successed: @escaping APISuccessed, failed: @escaping APIFailure) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.cacheBlocks.append((key, successed, failed))
    }
    
    mutating func cacheTask(key: Key, task: Moya.Cancellable) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.tasks[key] = task
    }
    
    mutating func resultSuccessed(_ response: Moya.Response, key: Key) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.cacheBlocks.forEach {
            $0.key == key ? $0.successed(response) : nil
        }
        self.tasks.removeValue(forKey: key)
        self.cacheBlocks.removeAll { $0.key == key }
    }
    
    mutating func resultFailed(_ error: APIFailureError, key: Key) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.cacheBlocks.forEach {
            $0.key == key ? $0.failed(error) : nil
        }
        self.tasks.removeValue(forKey: key)
        self.cacheBlocks.removeAll { $0.key == key }
    }
}
