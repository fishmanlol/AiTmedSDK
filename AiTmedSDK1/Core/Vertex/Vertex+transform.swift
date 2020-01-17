//
//  AiTmed+vertex+transform.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    func transform(args: CreateVertexArgs, completion: (Result<(Vertex, String), AiTmedError>) -> Void) {
        guard let jwt = OPTCodeJwt[args.uid] else {
            completion(.failure(.unkown))
            return
        }
        
        var vertex = Vertex()
        vertex.type = AiTmedType.user
        vertex.tage = args.tage
        vertex.uid = args.uid
        vertex.pk = args.pk
        vertex.esk = args.esk
        
        if let arguments = args as? UpdateVertexArgs {
            vertex.id = arguments.id
        }
        
        completion(.success((vertex, jwt)))
    }
}
