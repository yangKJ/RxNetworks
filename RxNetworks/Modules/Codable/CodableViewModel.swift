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
import HollowCodable

class CodableViewModel: NSObject {

    struct Input {
        let count: Int
    }

    struct Output {
        let items: Observable<[CodeableModel]>
    }
    
    func transform(input: Input) -> Output {
        let items = request(input.count).asObservable()
        
        return Output(items: items)
    }
}

extension CodableViewModel {
    
    func request(_ count: Int) -> Observable<[CodeableModel]> {
        CodableAPI.cache(count).request().asObservable()
            .deserialized(ApiResponse<[CodeableModel]>.self, mapping: CodeableModel.self)
            .compactMap({ $0.data })
            .observe(on: MainScheduler.instance)
            .catchAndReturn([])
    }
}

public extension Observable where Element: Any {
    
    @discardableResult func deserialized<T: Codable>(_ type: T.Type, mapping: MappingCodable.Type) -> Observable<T> {
        return self.map { element -> T in
            return try Decodering<T>.decodering(mapping, element: element)
        }
    }
}

extension ApiResponse {
    public static func onErrorRecover(_ err: Swift.Error)-> SharedSequence<DriverSharingStrategy, ApiResponse<T>> {
        let __err = err as NSError
        return Driver<ApiResponse<T>>.just(ApiResponse<T>(code: __err.code, message: __err.localizedDescription))
    }
}
