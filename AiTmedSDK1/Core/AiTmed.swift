//
//  AiTmed.swift
//  AiTmed-framework
//
//  Created by Yi Tong on 11/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//The SDK has three layers
//1. grpc layer - call low level grpc
//2. conversion layer - convert paraments from application layer to edge, vertex, doc
//3. application layer - call conversion layer, expose to outside

//core folder include grpc layer and conversion layer
//grpc layer is included in AiTmed+grpc file
//conversion layers are included in AiTmed+create, AiTmed+retrieve, AiTmed+update, AiTmed+delete

import Foundation
import Alamofire

typealias Edge = Aitmed_Ecos_V1beta1_Edge
typealias Vertex = Aitmed_Ecos_V1beta1_Vertex
typealias Doc = Aitmed_Ecos_V1beta1_Doc

public class AiTmed {
    ///Only use credential after login or create user!!!
    var c: Credential!
    ///Encryption tool
    let e = Encryption()
    let grpcTimeout: TimeInterval = 5
//    let host1 = "configd.aitmed.com: 9090"
    let host = "testapi2.aitmed.com:443"
    var client: Aitmed_Ecos_V1beta1_EcosAPIServiceClient
    static let shared = AiTmed()
    init() {
        client = Aitmed_Ecos_V1beta1_EcosAPIServiceClient(address: host, secure: true)
        client.timeout = grpcTimeout
    }
    var OPTCodeJwt: [String: String] = [:]
    
    func checkStatus() -> AiTmedError? {
        if let c = c {
            if c.status == .login {
                return nil
            } else if c.status == .locked {
                return .credentialFailed(.passwordNeeded)
            }
        }
        
        return .credentialFailed(.signInNeeded)
    }
    
    public static func hasCredential(for phoneNumber: String) -> Bool {
        if let _ = shared.c {
            return true
        } else if let cre = Credential(phoneNumber: phoneNumber) {
            print(cre.esk)
            return true
        } else {
            return false
        }
    }
    
    public static func logout() {
        shared.c?.sk = nil
    }
    
    public static func deleteUser(completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        deleteVertex(id: shared.c.userId, completion: completion)
    }
    
    public static func createUser(args: CreateUserArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let jwt = shared.OPTCodeJwt[args.phoneNumber] else {
            completion(.failure(.unkown))
            return
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (_vertex, sk)):
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
    
    
    
    
    
    public static func sendOPTCode(args: SendOPTCodeArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                shared._createEdge(edge: edge, jwt: "", completion: { (result: Swift.Result<(Edge, String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (_, jwt)):
                        shared.OPTCodeJwt[args.phoneNumber] = jwt
                        completion(.success(()))
                    }
                })
            }
        }
    }
    

    
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
    
    
}
