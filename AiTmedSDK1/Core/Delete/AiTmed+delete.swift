//
//  AiTmed+delete.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    public static func deleteVertex(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        //Notebooks
        AiTmed.retrieveEdges(args: RetrieveEdgesArgs(ids: [], type: AiTmedType.notebook, maxCount: nil)) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edges):
                var success = true
                
                let group = DispatchGroup()
                for edge in edges {
                    deleteEdge(id: edge.id, completion: { (result) in
                        switch result {
                        case .failure(_):
                            success = false
                        case .success(_):
                            break
                        }
                    })
                }
                
                DispatchQueue.global().async {
                    let sem = DispatchSemaphore(value: 0)
                    
                    
                    if success {
                        shared._delete(ids: [id], jwt: shared.c.jwt, completion: { (result) in
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
//        shared._retreiveEdge(args: RetrieveNotebooksArgs(ids: [], maxCount: nil), jwt: shared.c.jwt) { (result) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let (edges, jwt)):
//                shared.c.jwt = jwt
//                var success = true
//
//                DispatchQueue.global().async {
//                    let sem = DispatchSemaphore(value: 0)
//                    for edge in edges {
//                        deleteEdge(id: edge.id, completion: { (result) in
//                            switch result {
//                            case .failure(_):
//                                success = false
//                            case .success(_):
//                                break
//                            }
//                            sem.signal()
//                        })
//
//                        sem.wait()
//                    }
//
//                    if success {
//                        shared._delete(ids: [id], jwt: shared.c.jwt, completion: { (result) in
//                            switch result {
//                            case .failure(_):
//                                completion(.failure(.unkown))
//                            case .success(let j):
//                                shared.c.jwt = j
//                                completion(.success(()))
//                            }
//                        })
//                    } else {
//                        completion(.failure(.unkown))
//                    }
//                }
//            }
//        }
    }
    
    public static func deleteEdge(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        shared._retrieveDoc(args: RetrieveDocArgs(folderID: id), jwt: shared.c.jwt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (docs, jwt)):
                shared.c.jwt = jwt
                var success = true
                
                DispatchQueue.global().async {
                    let sem = DispatchSemaphore(value: 0)
                    for doc in docs {
                        deleteDoc(id: doc.id, completion: { (result) in
                            switch result {
                            case .failure(let error):
                                success = false
                                break
                            case .success(_):
                                break
                            }
                            sem.signal()
                        })
                        sem.wait()
                    }
                    
                    if success {
                        shared._delete(ids: [id], jwt: shared.c.jwt, completion: { (result) in
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
    
    public static func deleteDoc(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        shared._delete(ids: [id], jwt: shared.c!.jwt) { (result: Swift.Result<String, AiTmedError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let jwt):
                shared.c.jwt = jwt
                completion(.success(()))
            }
        }
    }
}
