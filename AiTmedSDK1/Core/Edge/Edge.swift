//
//  Edge.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Create
    static func createEdge(args: CreateEdgeArgs, completion: @escaping (Result<Edge, AiTmedError>) -> Void) {
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
    
    //MARK: - Update
    static func updateEdge(args: UpdateEdgeArgs, completion: @escaping (Result<Edge, AiTmedError>) -> Void) {
        createEdge(args: args, completion: completion)
    }
    
    //MARK: - Retrieve
    ///for convinience, we can retrieve single edge
    static func retrieveEdge(args: RetrieveSingleArgs, completion: @escaping (Result<Edge, AiTmedError>) -> Void) {
        retrieveEdges(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edges):
                guard let edge = edges.first else {
                    completion(.failure(.unkown))
                    return
                }
                
                completion(.success(edge))
            }
        }
    }
    
    static func retrieveEdges(args: RetrieveArgs, completion: @escaping (Result<[Edge], AiTmedError>) -> Void) {
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
    
    //MARK: - Delete
    static func deleteEdge(args: DeleteArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        shared._retrieveDoc(args: RetrieveDocArgs(folderID: args.id), jwt: shared.c.jwt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (docs, jwt)):
                shared.c.jwt = jwt
                var success = true
                
                DispatchQueue.global().async {
                    let sem = DispatchSemaphore(value: 0)
                    for doc in docs {
                        deleteDocument(args: DeleteArgs(id: doc.id), completion: { (result) in
                            switch result {
                            case .failure(let error):
                                print(error.localizedDescription)
                                success = false
                            case .success(_):
                                break
                            }
                            sem.signal()
                        })
                        sem.wait()
                    }
                    
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
                }
            }
        }
    }
}




