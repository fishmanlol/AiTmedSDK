//
//  AiTmed+update.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    static func updateEdge(args: UpdateEdgeArgs, completion: @escaping (Swift.Result<Edge, AiTmedError>) -> Void) {
        var jwt: String = ""
        if let c = shared.c {
            jwt = c.jwt
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                shared._createEdge(edge: edge, jwt: jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edge, jwt)):
                        shared.c.jwt = jwt
                        completion(.success(edge))
                    }
                })
            }
        }
    }
}

///Transform
extension AiTmed {
    func transform(args: UpdateEdgeArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        if let error = checkStatus() {
            completion(.failure(error))
            return
        }
        
        var edge = Edge()
        edge.type = args.type
        edge.name = args.name
        edge.stime = args.stime
        edge.bvid = args.bvid
        
        completion(.success(edge))
    }
}
