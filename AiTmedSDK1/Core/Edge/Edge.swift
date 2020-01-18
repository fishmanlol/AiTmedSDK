//
//  Edge.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//
import PromiseKit
import Foundation


extension AiTmed {
    //MARK: - Create
    static func createEdge(args: CreateEdgeArgs) -> Promise<Edge> {
        let jwt: String
        
        if args.type == AiTmedType.sendOPTCode || args.type == AiTmedType.login {//if send verification code, jwt == "", we use login to exchange jwt
            jwt = ""
        } else if args.type == AiTmedType.retrieveCredential {//if retrieve credential, use temporary jwt
            jwt = AiTmed.shared.tmpJWT
        } else {
            jwt = AiTmed.shared.c.jwt
        }
        
        return Promise<Edge> { resolver in
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let edge):
                    shared.g.createEdge(edge: edge, jwt: jwt, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            resolver.reject(error)
                        case .success(let (edge, jwt)):
                            if args.type == AiTmedType.sendOPTCode {//if send verification code, returned jwt saved in tmpJWT
                                shared.tmpJWT = jwt
                            } else if args.type == AiTmedType.retrieveCredential {//if retrieve credential, save credential
                                guard let dict = edge.name.toJSONDict(),
                                        let phoneNumber = dict[AiTmedNameKey.phoneNumber.rawValue] as? String,
                                        let credential = Credential(json: edge.deat, for: phoneNumber) else {
                                            resolver.reject(AiTmedError.unkown)
                                            return
                                }
                                credential.save()
                                shared.c = credential
                            } else {
                                shared.c.jwt = jwt
                            }
                            resolver.fulfill(edge)
                        }
                    })
                }
            }
        }
    }
    
    //MARK: - Update
    static func updateEdge(args: UpdateEdgeArgs) -> Promise<Edge> {
        return createEdge(args: args)
    }
    
    //MARK: - Retrieve
    ///for convinience, we can retrieve single edge
    static func retrieveEdge(args: RetrieveSingleArgs) -> Promise<Edge> {
        return retrieveEdges(args: args).firstValue
    }
    
    static func retrieveEdges(args: RetrieveArgs) -> Promise<[Edge]> {
        return Promise<[Edge]> { resolver in
            if let error = shared.checkStatus() {
                resolver.reject(error)
                return
            }
            
            shared.g.retreiveEdges(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let (edges, jwt)):
                    shared.c.jwt = jwt
                    resolver.fulfill(edges)
                }
            })
        }
    }
    
    //MARK: - Delete
    static func deleteEdge(args: DeleteArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
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




