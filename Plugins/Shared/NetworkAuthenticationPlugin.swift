//
//  NetworkAuthenticationPlugin.swift
//  Booming
//
//  Created by Condy on 2024/6/1.
//

import Foundation
import Alamofire
import Moya

/// 生成授权凭证。用户没有登陆时，可以不生成。
/// let credential = OAuthCredential.restore()
/// 生成授权中心
/// let authenticator = OAuthenticator()
/// 使用授权中心和凭证配置拦截器
/// let interceptor = OAuthentication(authenticator: authenticator, credential: credential)
public struct NetworkAuthenticationPlugin {
    
    public let interceptor: RequestInterceptor
    
    public init(interceptor: RequestInterceptor) {
        self.interceptor = interceptor
    }
}

extension NetworkAuthenticationPlugin: PluginSubType {
    
    public var pluginName: String {
        "Authentication"
    }
}

/// The `Authentication` class manages the queuing and threading complexity of authenticating requests.
/// It relies on an `Authenticator` type to handle the actual `URLRequest` authentication and `Credential` refresh.
public class OAuthentication<AuthenticatorType>: RequestInterceptor where AuthenticatorType: Authenticator {
    
    /// Type of credential used to authenticate requests.
    public typealias Credential = AuthenticatorType.Credential
    
    // MARK: - Helper Types
    
    /// Type that defines a time window used to identify excessive refresh calls. When enabled, prior to executing a
    /// refresh, the `Authentication` compares the timestamp history of previous refresh calls against the
    /// `RefreshWindow`. If more refreshes have occurred within the refresh window than allowed, the refresh is
    /// cancelled and an `AuthorizationError.excessiveRefresh` error is thrown.
    public struct RefreshWindow {
        /// `TimeInterval` defining the duration of the time window before the current time in which the number of
        /// refresh attempts is compared against `maximumAttempts`. For example, if `interval` is 30 seconds, then the
        /// `RefreshWindow` represents the past 30 seconds. If more attempts occurred in the past 30 seconds than
        /// `maximumAttempts`, an `.excessiveRefresh` error will be thrown.
        public let interval: TimeInterval
        
        /// Total refresh attempts allowed within `interval` before throwing an `.excessiveRefresh` error.
        public let maximumAttempts: Int
        
        /// Creates a `RefreshWindow` instance from the specified `interval` and `maximumAttempts`.
        ///
        /// - Parameters:
        ///   - interval:        `TimeInterval` defining the duration of the time window before the current time.
        ///   - maximumAttempts: The maximum attempts allowed within the `TimeInterval`.
        public init(interval: TimeInterval = 30.0, maximumAttempts: Int = 5) {
            self.interval = interval
            self.maximumAttempts = maximumAttempts
        }
    }
    
    private struct AdaptOperation {
        let urlRequest: URLRequest
        let session: Session
        let completion: (Result<URLRequest, Error>) -> Void
    }
    
    private enum AdaptResult {
        case adapt(Credential)
        case doNotAdapt(AuthenticationError)
        case adaptDeferred
    }
    
    private struct MutableState {
        var credential: Credential?
        
        var isRefreshing = false
        var refreshTimestamps: [TimeInterval] = []
        var refreshWindow: RefreshWindow?
        
        var adaptOperations: [AdaptOperation] = []
        var requestsToRetry: [(RetryResult) -> Void] = []
    }
    
    // MARK: - Properties
    
    /// The `Credential` used to authenticate requests.
    public var credential: Credential? {
        get { $mutableState.credential }
        set { $mutableState.credential = newValue }
    }
    
    let authenticator: AuthenticatorType
    let queue = DispatchQueue(label: "org.alamofire.authentication.inspector")
    
    @Protected private var mutableState: MutableState
    
    // MARK: - Initialization
    
    /// Creates an `Authentication` instance from the specified parameters.
    ///
    /// A `nil` `RefreshWindow` will result in the `Authentication` not checking for excessive refresh calls.
    /// It is recommended to always use a `RefreshWindow` to avoid endless refresh cycles.
    ///
    /// - Parameters:
    ///   - authenticator: The `Authenticator` type.
    ///   - credential:    The `Credential` if it exists. `nil` by default.
    ///   - refreshWindow: The `RefreshWindow` used to identify excessive refresh calls. `RefreshWindow()` by default.
    public init(authenticator: AuthenticatorType,
                credential: Credential? = nil,
                refreshWindow: RefreshWindow? = RefreshWindow()) {
        self.authenticator = authenticator
        mutableState = MutableState(credential: credential, refreshWindow: refreshWindow)
    }
    
    // MARK: - Adapt
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var authenticatedRequest = urlRequest
        if let credential = mutableState.credential {
            authenticator.apply(credential, to: &authenticatedRequest)
        }
        completion(.success(authenticatedRequest))
    }
    
    // MARK: - Retry
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // Do not attempt retry if there was not an original request and response from the server.
        guard let urlRequest = request.request, let response = request.response else {
            completion(.doNotRetry)
            return
        }
        
        // Do not attempt retry unless the `Authenticator` verifies failure was due to authentication error (i.e. 401 status code).
        guard authenticator.didRequest(urlRequest, with: response, failDueToAuthenticationError: error) else {
            completion(.doNotRetry)
            return
        }
        
        // Do not attempt retry if there is no credential.
        guard let credential = credential else {
            let error = AuthenticationError.missingCredential
            completion(.doNotRetryWithError(error))
            return
        }
        
        // Retry the request if the `Authenticator` verifies it was authenticated with a previous credential.
        guard authenticator.isRequest(urlRequest, authenticatedWith: credential) else {
            completion(.retry)
            return
        }
        
        $mutableState.write { mutableState in
            mutableState.requestsToRetry.append(completion)
            guard !mutableState.isRefreshing else { 
                return
            }
            refresh(credential, for: session, insideLock: &mutableState)
        }
    }
    
    // MARK: - Refresh
    
    private func refresh(_ credential: Credential, for session: Session, insideLock mutableState: inout MutableState) {
        guard !isRefreshExcessive(insideLock: &mutableState) else {
            let error = AuthenticationError.excessiveRefresh
            handleRefreshFailure(error, insideLock: &mutableState)
            return
        }
        mutableState.refreshTimestamps.append(ProcessInfo.processInfo.systemUptime)
        mutableState.isRefreshing = true
        // Dispatch to queue to hop out of the lock in case authenticator.refresh is implemented synchronously.
        queue.async {
            self.authenticator.refresh(credential, for: session) { result in
                self.$mutableState.write { mutableState in
                    switch result {
                    case let .success(credential):
                        self.handleRefreshSuccess(credential, insideLock: &mutableState)
                    case let .failure(error):
                        self.handleRefreshFailure(error, insideLock: &mutableState)
                    }
                }
            }
        }
    }
    
    private func isRefreshExcessive(insideLock mutableState: inout MutableState) -> Bool {
        guard let refreshWindow = mutableState.refreshWindow else {
            return false
        }
        let refreshWindowMin = ProcessInfo.processInfo.systemUptime - refreshWindow.interval
        let raww = mutableState.refreshTimestamps.reduce(into: 0) { attempts, timestamp in
            guard refreshWindowMin <= timestamp else { return }
            attempts += 1
        }
        let isRefreshExcessive = raww >= refreshWindow.maximumAttempts
        return isRefreshExcessive
    }
    
    private func handleRefreshSuccess(_ credential: Credential, insideLock mutableState: inout MutableState) {
        mutableState.credential = credential
        let adaptOperations = mutableState.adaptOperations
        let requestsToRetry = mutableState.requestsToRetry
        mutableState.adaptOperations.removeAll()
        mutableState.requestsToRetry.removeAll()
        mutableState.isRefreshing = false
        // Dispatch to queue to hop out of the mutable state lock
        queue.async {
            adaptOperations.forEach { self.adapt($0.urlRequest, for: $0.session, completion: $0.completion) }
            requestsToRetry.forEach { $0(.retry) }
        }
    }
    
    private func handleRefreshFailure(_ error: Error, insideLock mutableState: inout MutableState) {
        let adaptOperations = mutableState.adaptOperations
        let requestsToRetry = mutableState.requestsToRetry
        mutableState.adaptOperations.removeAll()
        mutableState.requestsToRetry.removeAll()
        mutableState.isRefreshing = false
        // Dispatch to queue to hop out of the mutable state lock
        queue.async {
            adaptOperations.forEach { $0.completion(.failure(error)) }
            requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
        }
    }
}

private protocol Lock {
    func lock()
    func unlock()
}

extension Lock {
    /// Executes a closure returning a value while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    ///
    /// - Returns:           The value the closure generated.
    func around<T>(_ closure: () throws -> T) rethrows -> T {
        lock(); defer { unlock() }
        return try closure()
    }
    
    /// Execute a closure while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    func around(_ closure: () throws -> Void) rethrows {
        lock(); defer { unlock() }
        try closure()
    }
}

#if os(Linux) || os(Windows) || os(Android)
extension NSLock: Lock { }
#endif

#if canImport(Darwin)
/// An `os_unfair_lock` wrapper.
final class UnfairLock: Lock {
    private let unfairLock: os_unfair_lock_t
    
    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    fileprivate func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
#endif

/// A thread-safe wrapper around a value.
@propertyWrapper @dynamicMemberLookup final class Protected<T> {
#if canImport(Darwin)
    private let lock = UnfairLock()
#elseif os(Linux) || os(Windows) || os(Android)
    private let lock = NSLock()
#endif
    private var value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    /// The contained value. Unsafe for anything more than direct read or write.
    var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }
    
    var projectedValue: Protected<T> { self }
    
    init(wrappedValue: T) {
        value = wrappedValue
    }
    
    /// Synchronously read or transform the contained value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The return value of the closure passed.
    func read<U>(_ closure: (T) throws -> U) rethrows -> U {
        try lock.around { try closure(self.value) }
    }
    
    /// Synchronously modify the protected value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The modified value.
    @discardableResult func write<U>(_ closure: (inout T) throws -> U) rethrows -> U {
        try lock.around { try closure(&self.value) }
    }
    
    subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }
    
    subscript<Property>(dynamicMember keyPath: KeyPath<T, Property>) -> Property {
        lock.around { value[keyPath: keyPath] }
    }
}
