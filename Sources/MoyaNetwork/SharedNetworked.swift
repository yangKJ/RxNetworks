//
//  SharedNetworked.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//

import Foundation
import Moya

/// 共享网络
struct SharedNetworked {
    typealias Key = String
    
    public static var shared = SharedNetworked()
    
    private let lock = NSLock()
    
    private var tasks = [Key: Moya.Cancellable]()
    
    private var cacheBlocks = [(key: Key, success: APISuccess, failure: APIFailure)]()
}

extension SharedNetworked {
    
    func readTask(key: Key) -> Cancellable? {
        self.lock.lock()
        defer { lock.unlock() }
        return self.tasks[key]
    }
    
    mutating func cacheBlocks(key: Key, success: @escaping APISuccess, failure: @escaping APIFailure) {
        self.lock.lock()
        defer { lock.unlock() }
        self.cacheBlocks.append((key, success, failure))
    }
    
    mutating func cacheTask(key: Key, task: Cancellable) {
        self.lock.lock()
        defer { lock.unlock() }
        self.tasks[key] = task
    }
    
    mutating func result(_ type: Result<APISuccessJSON, APIFailureError>, key: Key) {
        self.lock.lock()
        defer { lock.unlock() }
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
    
    func requestLink(with target: TargetType) -> String {
        var parameters: APIParameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        let paramString = RxNetworks.X.sort(parameters: parameters)
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
}
