//
//  ValueTransformable.swift
//  CodableExample
//
//  Created by Condy on 2024/7/3.
//

import Foundation

/// A TransformType simply defines a static function that transforms a value.
public protocol TransformType {
    associatedtype Object
    associatedtype JSON
    
    /// transform from json to object
    func transformFromJSON(_ value: Any) -> Object?
    
    /// transform to json from object
    func transformToJSON(_ value: Object) -> JSON?
}

extension TransformType {
    
    public var objectClassName: String {
        String(describing: Object.self)
    }
}
