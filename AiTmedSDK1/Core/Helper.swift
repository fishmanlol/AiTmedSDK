//
//  Helper.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

extension AiTmed {
    //MARK: - Retrieve xesk pair from edge
//    static func xeskPairInEdge(_ id: Data, completion: @escaping (Result<(Key, Key)?, AiTmedError>) -> Void) {
//
//        AiTmed.retrieveEdges(args: RetrieveSingleArgs(id: id)) { (result) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let edges):
//                if let edge = edges.first, edge.besak.count > 0, edge.eesak.count > 0  {
//                    completion(.success((Key(edge.besak), Key(edge.eesak))))
//                } else {
//                    completion(.success(nil))
//                }
//            }
//        }
//    }
    
//    static func xeskPairInEdge(_ id: Data) -> Promise<(Key, Key)?> {
//        return Promise<(Key, Key)?> { resolver in
//            firstly { () -> Promise<Edge> in
//                let args = RetrieveSingleArgs(id: id)
//                return retrieveEdge(args: args)
//            }.done { (edge) in
//                if !edge.besak.isEmpty && !edge.eesak.isEmpty {
//                    resolver.fulfill((Key(edge.besak), Key(edge.eesak)))
//                } else {
//                    resolver.fulfill(nil)
//                }
//            }.catch { (error) in
//                resolver.reject(error)
//            }
//        }
//    }
    
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
}
