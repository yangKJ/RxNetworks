//
//  RxHandyJSON.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`HandyJSON`文档
/// https://github.com/alibaba/HandyJSON

import HandyJSON

#if canImport(RxSwift)
import RxSwift

extension Observable where Element: Any {
    
    @discardableResult
    public func mapHandyJSON<H: HandyJSON>(_ type: H.Type) -> Observable<H> {
        return self.map { element -> H in
            if let model = Deserialized<H>.toModel(with: element) {
                return model
            }
            throw HandyJSONError.mapModel
        }
    }
    
    @discardableResult
    public func mapHandyJSON2Model<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<H> {
        return self.map { element -> H in
            if let model = Deserialized<H>.toModel(with: element, atKeyPath: keyPath) {
                return model
            }
            throw HandyJSONError.mapModel
        }
    }
    
    @discardableResult
    public func mapHandyJSON2Array<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<[H]> {
        return self.map { element -> [H] in
            if let array = Deserialized<H>.toArray(with: element, atKeyPath: keyPath) {
                return array
            }
            throw HandyJSONError.mapArray
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Any {
    
    @discardableResult
    public func mapHandyJSON<H: HandyJSON>(_ type: H.Type) -> Observable<H> {
        self.asObservable().mapHandyJSON(H.self)
    }
    
    @discardableResult
    public func mapHandyJSON2Model<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<H> {
        self.asObservable().mapHandyJSON2Model(H.self, atKeyPath: keyPath)
    }
    
    @discardableResult
    public func mapHandyJSON2Array<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<[H]> {
        self.asObservable().mapHandyJSON2Array(H.self, atKeyPath: keyPath)
    }
}

#endif
