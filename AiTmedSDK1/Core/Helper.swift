//
//  Helper.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

extension AiTmed {
    static func beskInEdge(_ id: Data) -> Swift.Result<Key?, AiTmedError> {
        guard let edge = try? retrieveEdge(args: RetrieveSingleArgs(id: id)).wait() else { return .failure(AiTmedError.unkown)}
        var besak: Key?
        if !edge.besak.isEmpty {
            besak = Key(edge.besak)
        }
        return .success(besak)
    }
    
    static func eeskInEdge(_ id: Data) -> Swift.Result<Key?, AiTmedError> {
        guard let edge = try? retrieveEdge(args: RetrieveSingleArgs(id: id)).wait() else { return .failure(AiTmedError.unkown)}
        var eesak: Key?
        if !edge.eesak.isEmpty {
            eesak = Key(edge.eesak)
        }
        return .success(eesak)
    }
    
    //MARK: - Make sure each api call has permission
    func checkStatus() -> AiTmedError? {
        if let c = c {
            if c.status == .login {
                return nil
            } else if c.status == .locked {
                return .credentialFailed(.passwordNeeded)
            }
        }
        
        return .credentialFailed(.signInNeeded)
    }
    
    static func checkStatus() -> Promise<Void> {
        return Promise<Void> { resolver in
            if let c = shared.c {
                if c.status == .login {
                    resolver.fulfill(())
                } else if c.status == .locked {
                    resolver.reject(AiTmedError.credentialFailed(.passwordNeeded))
                }
            }
            
            resolver.reject(AiTmedError.credentialFailed(.signInNeeded))
        }
    }
    
    static func besakInEdge(_ id: Data) -> Promise<Key> {
        return DispatchQueue.global().async(.promise) { () -> Key in
            let edge = try retrieveEdge(args: RetrieveSingleArgs(id: id)).wait()
            
            guard !edge.besak.isEmpty else { throw AiTmedError.unkown }
            
            return Key(edge.besak)
        }
    }
    
    static func getSak(besak: Key, sendPK: Key, recvSK: Key) -> Promise<Key> {
        return Promise<Key> { resolver in
            if let sak = shared.e.generateSAK(xesak: besak, sendPublicKey: sendPK, recvSecretKey: recvSK) {
                resolver.fulfill(sak)
            } else {
                resolver.reject(AiTmedError.unkown)
            }
        }
    }
    
    static func zip(_ data: Data) -> Promise<Data> {
        return Promise<Data> { resolver in
            if let zipped = try? data.zip() {
                resolver.fulfill(zipped)
            } else {
                resolver.reject(AiTmedError.unkown)
            }
        }
    }
    
    static func encrypt(_ data: Data, sak: Key) -> Promise<Data> {
        return Promise<Data> { resolver in
            if let encryptedData = shared.e.sKeyEncrypt(secretKey: sak, data: [UInt8](data)) {
                resolver.fulfill(Data(encryptedData))
            } else {
                resolver.reject(AiTmedError.unkown)
            }
        }
    }
    
    static func upload(_ data: Data, to url: URLConvertible) -> Promise<Void> {
        return Promise<Void> { resolver in
            Alamofire.upload(data, to: url, method: .put, headers: nil).response  { (response) in
                guard let statusCode = response.response?.statusCode,
                    (200..<300).contains(statusCode) else {
                        
                        resolver.reject(response.error ?? AiTmedError.unkown)
                        return
                }
                
                resolver.fulfill(())
            }
        }
    }
    
    static func download(from url: URLConvertible) -> Promise<Data> {
        return Promise<Data> { resolver in
            Alamofire.download(url).responseData(completionHandler: { (response) in
                guard let statusCode = response.response?.statusCode,
                    (200..<300).contains(statusCode) else {
                        resolver.reject(response.error ?? AiTmedError.unkown)
                        return
                }
                
                switch response.result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let data):
                    resolver.fulfill(data)
                }
            })
        }
    }
}

extension StringProtocol {
    func toJSONDict() -> Promise<[String: Any]> {
        return Promise<[String: Any]> { resolver in
            if let data = self.data(using: .utf8),
                let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                resolver.fulfill(dict)
            } else {
                resolver.reject(AiTmedError.unkown)
            }
        }
    }
}

extension Dictionary where Key == AiTmedNameKey {
    func toJSON() -> Promise<String> {
        return Promise<String> { resolver in
            var newDict: [String: Value] = [:]
            for (key, value) in self {
                newDict[key.rawValue] = value
            }
            
            guard let data = try? JSONSerialization.data(withJSONObject: newDict, options: []),
                    let json = String(bytes: data, encoding: .utf8) else {
                resolver.reject(AiTmedError.unkown)
                return
            }
            
            resolver.fulfill(json)
        }
    }
}

extension Dictionary where Key == String {
    func toJSON() -> Promise<String> {
        return Promise<String> { resolver in
            guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
                let json = String(bytes: data, encoding: .utf8) else {
                    resolver.reject(AiTmedError.unkown)
                    return
            }
            
            resolver.fulfill(json)
        }
    }
}
