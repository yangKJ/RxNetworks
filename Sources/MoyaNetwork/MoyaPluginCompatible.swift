//
//  MoyaPluginCompatible.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/25.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

extension AccessTokenPlugin: PluginSubType {
    public var pluginName: String {
        return "AccessToken"
    }
}

extension CredentialsPlugin: PluginSubType {
    public var pluginName: String {
        return "Credentials"
    }
}

extension NetworkLoggerPlugin: PluginSubType {
    public var pluginName: String {
        return "Logger"
    }
}

extension NetworkActivityPlugin: PluginSubType {
    public var pluginName: String {
        return "Activity"
    }
}
