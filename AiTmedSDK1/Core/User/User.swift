//
//  User.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Has credential
    public static func hasCredential(for phoneNumber: String) -> Bool {
        if let _ = shared.c {
            return true
        } else if let _ = Credential(phoneNumber: phoneNumber) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Retrieve credential
    public static func retrieveCredential(args: RetrieveCredentialArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let _jwt = shared.OPTCodeJwt[args.phoneNumber] else {
            completion(.failure(.unkown))
            return
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _edge):
                shared._createEdge(edge: _edge, jwt: _jwt, completion: { (result: Swift.Result<(Edge, String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edge, jwt)):
                        if let dict = edge.deat.toJSONDict(),
                            let pkStr = dict[AiTmedDeatKey.pk.rawValue] as? String,
                            let pk = Key(pkStr),
                            let eskStr = dict[AiTmedDeatKey.esk.rawValue] as? String,
                            let esk = Key(eskStr),
                            let userIdStr = dict[AiTmedDeatKey.userId.rawValue] as? String,
                            let userIdBytes = shared.e.base642Bin(userIdStr) {
                            let userId = Data(userIdBytes)
                            let credential = Credential(phoneNumber: args.phoneNumber, pk: pk, esk: esk, userId: userId, jwt: jwt)
                            credential.save()
                            completion(.success(()))
                        } else {
                            print("decode deat of retreive credential failed")
                            completion(.failure(.unkown))
                        }
                    }
                })
            }
        }
    }
    
    //MARK: - Log in
    public static func login(args: LoginArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (_edge, credential)):
                shared._createEdge(edge: _edge, jwt: credential.jwt, completion: { (result: Swift.Result<(Edge, String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (_, jwt)):
                        shared.c = credential
                        shared.c?.jwt = jwt
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    //MARK: - Log out
    public static func logout() {
        shared.c?.sk = nil
    }
    
    //MARK: - Create user
    public static func createUser(args: CreateUserArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        DispatchQueue.global().async {
            guard let jwt = shared.OPTCodeJwt[args.phoneNumber] else {
                completion(.failure(.unkown))
                return
            }
            
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let (_vertex, sk)):
                    let result = shared.g.createVertex(vertex: _vertex, jwt: <#T##String#>)
                    shared._createVertex(vertex: _vertex, jwt: jwt, completion: { (result: Swift.Result<(Vertex, String), AiTmedError>) in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let (vertex, jwt)):
                            let credential = Credential(phoneNumber: args.phoneNumber,
                                                        pk: Key(vertex.pk),
                                                        esk: Key(vertex.esk),
                                                        sk: sk,
                                                        userId: vertex.id,
                                                        jwt: jwt)
                            credential.save()//todo
                            completion(.success(()))
                        }
                    })
                }
            }
        }
    }
    
    //MARK: - Delete user
    public static func deleteUser(completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        deleteVertex(args: DeleteArgs(id: shared.c.userId), completion: completion)
    }
    
    //MARK: - Send verification code
    public static func sendOPTCode(args: SendOPTCodeArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        DispatchQueue.global().async {
            let result = shared.transform(args: args)
            
            guard case let .success(edge) = result else {
                return
            }
            
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let edge):
                    let result = shared.g.createEdge(edge: edge, jwt: "")
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(_):
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
