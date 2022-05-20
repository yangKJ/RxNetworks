//
//  Transform.swift
//  RxNetworks
//
//  Created by Condy on 2022/5/12.
//

import Foundation
import RxSwift
import Moya

public typealias APIObservableJSON = RxSwift.Observable<Any>

extension X {
    struct RxSwift { }
}

extension X.RxSwift {
    
    static func transformAPIObservableJSON(_ result: MoyaResult?) -> APIObservableJSON {
        return APIObservableJSON.create { (observer) in
            guard let result = result else {
                return Disposables.create { }
            }
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let jsonObject = try response.mapJSON()
                    observer.onNext(jsonObject)
                    observer.onCompleted()
                } catch MoyaError.jsonMapping(let response) {
                    observer.onError(MoyaError.jsonMapping(response))
                } catch MoyaError.statusCode(let response) {
                    observer.onError(MoyaError.statusCode(response))
                } catch {
                    observer.onError(error)
                }
            case let .failure(error):
                observer.onError(error)
            }
            return Disposables.create { }
        }
    }
}
