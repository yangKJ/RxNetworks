//
//  NetworkSharedPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 共享网络插件
public struct NetworkSharedPlugin {
    
    public init() { }
}

extension NetworkSharedPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Shared"
    }
}
