//
//  AiTmed+Vertex.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

extension AiTmed {
    ///Create vertex
    static func createVertex(args: CreateVertexArgs) -> Promise<Vertex> {
        return Promise<Vertex> { resovler in
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    resovler.reject(error)
                case .success(let vertex):
                    shared.g.createVertex(vertex: vertex, jwt: shared.tmpJWT, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            resovler.reject(error)
                        case .success(let (vertex, jwt)):
                            let credential = Credential(phoneNumber: args.uid,
                                                        pk: Key(vertex.pk),
                                                        esk: Key(vertex.esk),
                                                        sk: Key(args.sk),
                                                        userId: vertex.id,
                                                        jwt: jwt)
                            credential.save()
                            shared.c = credential
                            resovler.fulfill(vertex)
                        }
                    })
                }
            }
        }
    }
    
    ///Delete vertex
    static func deleteVertex(args: DeleteArgs) -> Promise<Void> {
        return DispatchQueue.global().async(.promise, execute: { () -> Void in
            try checkStatus().wait()
            let deleteList = [AiTmedType.root, AiTmedType.notebook]
            let retrievePromises = deleteList.map {
                retrieveEdges(args: RetrieveArgs(ids: [], xfname: "", type: $0, maxCount: nil))
            }
            let allEdges = try when(fulfilled: retrievePromises).flatMapValues({$0}).wait()
            let deleteEdgePromises = allEdges.map {
                deleteEdge(args: DeleteArgs(id: $0.id))
            }
            try when(fulfilled: deleteEdgePromises).wait()
            return
        })
    }
    
//    static func _deleteVertex(args: DeleteArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
//        guard let c = shared.c, c.status == .login else {
//            completion(.failure(.credentialFailed(.credentialNeeded)))
//            return
//        }
//
//        let deleteList = [AiTmedType.root, AiTmedType.notebook]
//
//        var success = true
//
//        for item in deleteList {
//            group.enter()
//            let retrieveNotebookArgs = RetrieveArgs(ids: [], xfname: "bvid", type: item, maxCount: nil)
//            AiTmed.retrieveEdges(args: retrieveNotebookArgs) { (result) in
//                switch result {
//                case .failure(_):
//                    success = false
//                case .success(let edges):
//                    for edge in edges {
//                        group.enter()
//                        deleteEdge(args: DeleteArgs(id: edge.id), completion: { (result) in
//                            switch result {
//                            case .failure(_):
//                                success = false
//                            case .success(_):
//                                break
//                            }
//
//                            group.leave()
//                        })
//                    }
//
//                    group.notify(queue: DispatchQueue.global(), execute: {
//                        if success {
//                            shared._delete(ids: [args.id], jwt: shared.c.jwt, completion: { (result) in
//                                switch result {
//                                case .failure(_):
//                                    completion(.failure(.unkown))
//                                case .success(let j):
//                                    shared.c.jwt = j
//                                    completion(.success(()))
//                                }
//                            })
//                        } else {
//                            completion(.failure(.unkown))
//                        }
//                    })
//                }
//            }
//        }
//    }
    
    static func updateVertex(args: UpdateVertexArgs) -> Promise<Vertex> {
        return createVertex(args: args)
    }
    
    static func retrieveVertex(args: RetrieveSingleArgs, completion: @escaping (Swift.Result<Vertex, AiTmedError>) -> Void) {
        //todo
        fatalError()
    }
}
