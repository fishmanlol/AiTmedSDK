//
//  AiTmed+Vertex.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation


extension AiTmed {
    ///Create vertex
    static func createVertex(args: CreateVertexArgs, completion: @escaping (Result<Vertex, AiTmedError>) -> Void) {
        
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (vertex, jwt)):
                shared._createVertex(vertex: vertex, jwt: jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (vertex, jwt)):
                        shared.c.jwt = jwt
                        completion(.success(vertex))
                    }
                })
            }
        }
    }
    
    ///Delete vertex
    static func deleteVertex(args: DeleteArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        let deleteList = [AiTmedType.root, AiTmedType.notebook]
        let group = DispatchGroup()
        var success = true
        
        for item in deleteList {
            group.enter()
            let retrieveNotebookArgs = RetrieveArgs(ids: [], type: item, maxCount: nil)
            AiTmed.retrieveEdges(args: retrieveNotebookArgs) { (result) in
                switch result {
                case .failure(_):
                    success = false
                case .success(let edges):
                    for edge in edges {
                        group.enter()
                        deleteEdge(args: DeleteArgs(id: edge.id), completion: { (result) in
                            switch result {
                            case .failure(_):
                                success = false
                            case .success(_):
                                break
                            }
                            
                            group.leave()
                        })
                    }
                    
                    group.notify(queue: DispatchQueue.global(), execute: {
                        if success {
                            shared._delete(ids: [args.id], jwt: shared.c.jwt, completion: { (result) in
                                switch result {
                                case .failure(_):
                                    completion(.failure(.unkown))
                                case .success(let j):
                                    shared.c.jwt = j
                                    completion(.success(()))
                                }
                            })
                        } else {
                            completion(.failure(.unkown))
                        }
                    })
                }
            }
        }
    }
    
    static func updateVertex(args: UpdateVertexArgs, completion: @escaping (Result<Vertex, AiTmedError>) -> Void) {
        AiTmed.createVertex(args: args, completion: completion)
    }
    
    static func retrieveVertex(args: RetrieveSingleArgs, completion: @escaping (Result<Vertex, AiTmedError>) -> Void) {
        //todo
        fatalError()
    }
}
