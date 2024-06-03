//
//  HasProtocols.swift
//  Booming
//
//  Created by Condy on 2024/6/1.
//

import Foundation
import Moya

public protocol HasPluginsPropertyProtocol: PluginSubType {
    var plugins: APIPlugins { get set }
}

@available(*, deprecated, message: "Typo. Use `HasKeyAndDelayPropertyProtocol` instead", renamed: "HasKeyAndDelayPropertyProtocol")
public typealias PluginPropertiesable = HasKeyAndDelayPropertyProtocol

public protocol HasKeyAndDelayPropertyProtocol: PluginSubType {
    
    var key: String? { get set }
    
    /// Loading HUD delay hide time.
    var delay: Double { get }
}

extension HasKeyAndDelayPropertyProtocol {
    public var delay: Double {
        return 0
    }
}
