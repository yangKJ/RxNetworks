//
//  Deprecated.swift
//  Booming
//
//  Created by Condy on 2024/6/13.
//

import Foundation
import Moya

@available(*, deprecated, message: "Typo. Use `OutputResultBlock` instead", renamed: "OutputResultBlock")
public typealias LastNeverCallback = OutputResultBlock

@available(*, deprecated, message: "Typo. Use `OutputResult` instead", renamed: "OutputResult")
public typealias LastNeverResult = OutputResult

@available(*, deprecated, message: "Typo. Use `APIResultValue` instead", renamed: "APIResultValue")
public typealias APISuccessJSON = APIResultValue

public extension NetworkAPI {
    @available(*, deprecated, message: "Typo. Use `request:successed:failed:progress:queue:plugins:` instead")
    @discardableResult func HTTPRequest(
        success: @escaping (APIResultValue) -> Void,
        failure: @escaping APIFailure,
        progress: ProgressBlock? = nil,
        queue: DispatchQueue? = nil,
        plugins: APIPlugins = []
    ) -> Moya.Cancellable? {
        request(successed: { response in
            guard let json = response.bpm.mappedJson else {
                return
            }
            success(json)
        }, failed: failure, progress: progress, queue: queue, plugins: plugins)
    }
    
    @available(*, deprecated, message: "Typo. Use `request:successed:failed:progress:queue:plugins:` instead")
    @discardableResult
    func request(plugins: APIPlugins = [], complete: @escaping (Result<APIResultValue, APIFailureError>) -> Void) -> Moya.Cancellable? {
        HTTPRequest(success: { json in
            complete(.success(json))
        }, failure: { error in
            complete(.failure(error))
        }, plugins: plugins)
    }
}

extension X {
    @available(*, deprecated, message: "Use HUDs.removeAll")
    public static func removeAllAtLevelStatusBarWindow() {
        HUDs.removeAll()
    }
    
    @available(*, deprecated, message: "Use HUDs.removeLoadingHUDs")
    public static func removeLoadingHUDs() {
        HUDs.removeLoadingHUDs()
    }
    
    @available(*, deprecated, message: "Use HUDs.readHUD:")
    public static func readHUD(key: String) -> LevelStatusBarWindowController? {
        HUDs.readHUD(key: key)
    }
    
    @available(*, deprecated, message: "Use HUDs.saveHUD:viewController:")
    public static func saveHUD(key: String, viewController: LevelStatusBarWindowController) {
        HUDs.saveHUD(key: key, viewController: viewController)
    }
    
    @available(*, deprecated, message: "Use HUDs.removeHUD:")
    @discardableResult public static func removeHUD(key: String?) -> LevelStatusBarWindowController? {
        HUDs.removeHUD(key: key)
    }
}

extension BoomingSetup {
    @available(*, deprecated, message: "Use `NetworkAuthenticationPlugin` add to `BoomingSetup.basePlugins`")
    /// It is recommended to use plug-in mode to add interceptor.
    /// You can also add it to the `BoomingSetup.basePlugins`.
    public static var interceptor: RequestInterceptor? = nil
    
    @available(*, deprecated, message: "Use `BoomingSetup.debuggingLogOption`, if you set false correspond to `BoomingSetup.debuggingLogOption = .nothing`")
    /// Whether to add the Debugging plugin by default.
    public static var addDebugging: Bool = true {
        didSet {
            if !addDebugging {
                #if BOOMING_PLUGINGS_FEATURES
                debuggingLogOption = .nothing
                #endif
            }
        }
    }
}
