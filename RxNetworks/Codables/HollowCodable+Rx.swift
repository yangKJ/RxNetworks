//
//  HollowCodable+Rx.swift
//  RxNetworks_Example
//
//  Created by Condy on 2024/7/28.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import HollowCodable

public extension Observable where Element: Any {
    
    @discardableResult func deserialized<T>(_ type: T.Type) -> Observable<T> where T: HollowCodable {
        return self.map { element -> T in
            return try T.deserialize(element: element)
        }
    }
    
    @discardableResult func deserialized<T>(_ type: [T].Type) -> Observable<[T]> where T: HollowCodable {
        return self.map { element -> [T] in
            return try [T].deserialize(element: element)
        }
    }
    
    @discardableResult func deserialized<T>(_ type: T.Type) -> Observable<ApiResponse<T.DataType>> where T: HasResponsable, T.DataType: HollowCodable {
        return self.map { element -> ApiResponse<T.DataType> in
            return try T.deserialize(element: element)
        }
    }
    
    @discardableResult func deserialized<T>(_ type: T.Type) -> Observable<ApiResponse<[T.DataType.Element]>> where T: HasResponsable, T.DataType: Collection, T.DataType.Element: HollowCodable {
        return self.map { element -> ApiResponse<[T.DataType.Element]> in
            return try T.deserialize(element: element)
        }
    }
}
