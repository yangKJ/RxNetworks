//
//  RxMoyaProvider.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/5.
//

///`Moya/RxSwift`文档
/// https://github.com/Moya/Moya/tree/master/Sources/RxMoya

@_exported import RxSwift
@_exported import Moya

extension MoyaProvider: ReactiveCompatible { }

public extension Reactive where Base: MoyaProvider<MultiTarget> {
    
    /// Designated request-making method.
    /// - Parameters:
    ///   - api: Request body
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single sequence JSON object.
    func request(api: NetworkAPI, callbackQueue: DispatchQueue? = nil) -> APISingleJSON {
        var single: APISingleJSON = APISingleJSON.create { single in
            let token = base.request(.target(api), callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        let json = try response.mapJSON()
                        single(.success(json))
                    } catch MoyaError.jsonMapping(let response) {
                        single(.failure(MoyaError.jsonMapping(response)))
                    } catch MoyaError.statusCode(let response) {
                        single(.failure(MoyaError.statusCode(response)))
                    } catch {
                        single(.failure(error))
                    }
                case let .failure(error):
                    single(.failure(error))
                }
            }
            return Disposables.create {
                token.cancel()
            }
        }
        if api.retry > 0 {
            single = single.retry(api.retry) // Number of retries after failed.
        }
        return single
    }
}
