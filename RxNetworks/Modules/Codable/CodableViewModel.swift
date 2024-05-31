//
//  CodableViewModel.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import RxNetworks
import RxCocoa

class CodableViewModel: NSObject {

    struct Input {
        let count: Int
    }

    struct Output {
        let items: Observable<[HollowCodeable]>
    }
    
    func transform(input: Input) -> Output {
        let items = request(input.count).asObservable()
        
        return Output(items: items)
    }
}

extension CodableViewModel {
    
    func request(_ count: Int) -> Observable<[HollowCodeable]> {
        CodableAPI.cache(count).request().asObservable()
            .deserialized(ApiResponse<[HollowCodeable]>.self)
            .compactMap({ $0.data })
            .observe(on: MainScheduler.instance)
            .catchAndReturn([])
    }
}

public extension Observable where Element: Any {
    
    @discardableResult func deserialized<T: Codable>(_ type: T.Type) -> Observable<T> {
        return self.map { element -> T in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try JSONSerialization.data(withJSONObject: element)
            let result = try decoder.decode(T.self, from: data)
            return result
        }
    }
}

extension ApiResponse {
    public static func onErrorRecover(_ err: Swift.Error)-> SharedSequence<DriverSharingStrategy, ApiResponse<T>> {
        let __err = err as NSError
        return Driver<ApiResponse<T>>.just(ApiResponse<T>(code: __err.code, message: __err.localizedDescription))
    }
}
