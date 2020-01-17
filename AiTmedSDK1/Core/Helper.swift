//
//  Helper.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Retrieve xesk pair from edge
    static func xeskPairInEdge(_ id: Data, completion: @escaping (Result<(Key, Key)?, AiTmedError>) -> Void) {
        AiTmed.retrieveEdges(args: RetrieveSingleArgs(id: id)) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edges):
                if let edge = edges.first, edge.besak.count > 0, edge.eesak.count > 0  {
                    completion(.success((Key(edge.besak), Key(edge.eesak))))
                } else {
                    completion(.success(nil))
                }
            }
        }
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
