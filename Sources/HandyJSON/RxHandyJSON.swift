//
//  RxHandyJSON.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/6.
//  https://github.com/yangKJ/RxNetworks

///`HandyJSON`文档
/// https://github.com/alibaba/HandyJSON

import RxSwift
@_exported import HandyJSON

public extension Observable where Element: Any {
    
    @discardableResult
    func mapHandyJSON<H: HandyJSON>(_ type: H.Type) -> Observable<H> {
        return self.map { element -> H in
            if let model = HandyJSON2Model(type, element: element) {
                return model
            }
            throw HandyJSONError.mapModel
        }
    }
    
    @discardableResult
    func mapHandyJSON2Model<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<H> {
        return self.map { element -> H in
            if let string = element as? String, let model = HandyJSON2Model(type, element: string) {
                return model
            }
            if let dictionary = element as? NSDictionary {
                if let keyPath = keyPath {
                    let value = dictionary.value(forKeyPath: keyPath)
                    if let model = HandyJSON2Model(type, element: value) {
                        return model
                    }
                } else if let model = HandyJSON2Model(type, element: dictionary) {
                    return model
                }
            }
            throw HandyJSONError.mapModel
        }
    }
    
    @discardableResult
    func mapHandyJSON2Array<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<[H]> {
        return self.map { element -> [H] in
            if let keyPath = keyPath, let dictionary = element as? NSDictionary {
                let value = dictionary.value(forKeyPath: keyPath)
                if let array = HandyJSON2Array(type, element: value) {
                    return array
                }
            }
            if let array = HandyJSON2Array(type, element: element) {
                return array
            }
            throw HandyJSONError.mapArray
        }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait, Element == Any {

    @discardableResult
    func mapHandyJSON<H: HandyJSON>(_ type: H.Type) -> Observable<H> {
        return self.asObservable().mapHandyJSON(H.self)
    }
    
    @discardableResult
    func mapHandyJSON2Model<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<H> {
        return self.asObservable().mapHandyJSON2Model(H.self, atKeyPath: keyPath)
    }
    
    @discardableResult
    func mapHandyJSON2Array<H: HandyJSON>(_ type: H.Type, atKeyPath keyPath: String? = nil) -> Observable<[H]> {
        return self.asObservable().mapHandyJSON2Array(H.self, atKeyPath: keyPath)
    }
}

private func HandyJSON2Model<H: HandyJSON>(_ type: H.Type, element: Any?) -> H? {
    if let string = element as? String, let model = H.deserialize(from: string) {
        return model
    }
    if let dictionary = element as? Dictionary<String, Any>, let model = H.deserialize(from: dictionary) {
        return model
    }
    if let dictionary = element as? [String : Any], let model = H.deserialize(from: dictionary) {
        return model
    }
    return nil
}

private func HandyJSON2Array<H: HandyJSON>(_ type: H.Type, element: Any?) -> [H]? {
    if let string = element as? String, let array = [H].deserialize(from: string) as? [H] {
        return array
    }
    if let array = [H].deserialize(from: element as? [Any]) as? [H] {
        return array
    }
    return nil
}
