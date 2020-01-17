//
//  Edge+transform.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    ///Create and update use same 
    func transform(args: CreateEdgeArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        //create user and send opt code don't need to check status
        if args.type != AiTmedType.user && args.type != AiTmedType.sendOPTCode {
            if  let error = checkStatus() {
                completion(.failure(error))
                return
            }
        }
        
        var edge = Edge()
        edge.type = args.type
        edge.name = args.name
        edge.stime = args.stime
        
        if let bivd = args.bvid {
            edge.bvid = bivd
        }
        
        if let besak = args.besak {
            edge.besak = besak
        }
        
        if let eesak = args.eesak {
            edge.eesak = eesak
        }
        
        if let arguments = args as? UpdateEdgeArgs {
            edge.id = arguments.id
        }
        
        completion(.success(edge))
    }
}
