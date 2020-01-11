//
//  AiTmed+retrieve.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    static func retrieveEdges(args: RetrieveEdgesArgs, completion: @escaping (Swift.Result<[Edge], AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _args):
                shared._retreiveEdges(args: _args, jwt: shared.c.jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edges, jwt)):
                        shared.c.jwt = jwt
                        completion(.success(edges))
                    }
                })
            }
        }
    }
    
    func transform(args: RetrieveEdgesArgs, completion: (Result<RetrieveEdgesArgs, AiTmedError>) -> Void) {
        if let error = checkStatus() {
            completion(.failure(error))
            return
        }
        completion(.success(args))
    }
}
