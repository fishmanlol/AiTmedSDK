//
//  AiTmed.swift
//  AiTmed-framework
//
//  Created by Yi Tong on 11/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

typealias Edge = Aitmed_Ecos_V1beta1_Edge
typealias Vertex = Aitmed_Ecos_V1beta1_Vertex
typealias Doc = Aitmed_Ecos_V1beta1_Doc

public class AiTmed {
    ///Only use credential after login or create user!!!
    private var c: Credential?
    ///Encryption tool
    private let e = Encryption()
    private let host = "testapi2.aitmed.com:443"
    private var client: Aitmed_Ecos_V1beta1_EcosAPIServiceClient
    private static let shared = AiTmed()
    private init() { client = Aitmed_Ecos_V1beta1_EcosAPIServiceClient(address: host, secure: true) }
    private var OPTCodeJwt: [String: String] = [:]
    
    public static func hasCredential(for phoneNumber: String) -> Bool {
        if shared.c == nil {
            shared.c =  Credential(phoneNumber: phoneNumber)
        }
        return shared.c != nil
    }
    
    public static func logout() {
        shared.c?.sk = nil
    }
    
    public static func retrieveNotebooks(args: RetrieveNotebooksArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let retrieveEdgeArgs):
                shared._retreiveEdge(args: retrieveEdgeArgs, jwt: shared.c!.jwt, completion: { (result: Result<([Edge], String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edges, jwt)):
                        shared.c?.jwt = jwt
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    public static func createNoteBook(args: CreateOrUpdateNotebookArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edge, jwt)):
                        shared.c?.jwt = jwt
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    public static func updateNotebook(args: CreateOrUpdateNotebookArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(var edge):
                edge.id = shared.c!.userId
                shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edge, jwt)):
                        shared.c?.jwt = jwt
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    public static func removeNotebook(ids: [Data], completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        guard let c = shared.c, c.status == .login else {
            completion(.failure(.credentialFailed(.signinRequired)))
            return
        }
        shared._deleteEdge(ids: ids, jwt: shared.c!.jwt) { (result: Result<String, AiTmedError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let jwt):
                shared.c?.jwt = jwt
                completion(.success(()))
            }
        }
    }
    
    public static func sendOPTCode(args: SendOPTCodeArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                shared._createEdge(edge: edge, jwt: "", completion: { (result: Result<(Edge, String), AiTmedError>) in
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
    
    public static func createUser(args: CreateUserArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        guard let jwt = shared.OPTCodeJwt[args.phoneNumber] else {
            completion(.failure(.unkown))
            return
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (_vertex, sk)):
                shared._createVertex(vertex: _vertex, jwt: jwt, completion: { (result: Result<(Vertex, String), AiTmedError>) in
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
                        credential.save()
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    public static func login(args: LoginArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (_edge, credential)):
                shared._createEdge(edge: _edge, jwt: credential.jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
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
    
    public static func retrieveCredential(args: RetrieveCredentialArgs, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        guard let _jwt = shared.OPTCodeJwt[args.phoneNumber] else {
            completion(.failure(.unkown))
            return
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let _edge):
                shared._createEdge(edge: _edge, jwt: _jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
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

//MARK: - grpc layer
extension AiTmed {
    
    ///Create edge: pass out jwt
    private func _createEdge(edge: Edge, jwt: String, completion: @escaping (Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("create edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { (response, result) in
                guard let response = response else {
                    print("create edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("Create edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else if response.code == 1020 {
                    completion(.failure(.apiResultFailed(.userNotExist)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Retreive edge
    private func _retreiveEdge(args: RetrieveEdgeArgs, jwt: String, completion: @escaping (Result<([Edge], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.id = args.ids
        request.objType = ObjectType.edge.code
        request.jwt = jwt
        request.type = args.type
        request.xfname = "bvid"
        if let maxCount = args.maxCount {
            request.maxcount = maxCount
        }
        
        print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.re(request) { (response, result) in
                guard let response = response else {
                    print("retrieve edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    private func _deleteEdge(ids: [Data], jwt: String, completion: @escaping (Result<String, AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        do {
            try client.dx(request) { (response, result) in
                guard let response = response else {
                    print("delete edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("delete edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success(response.jwt))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Update edge
    private func _updateEdge(edge: Edge, jwt: String, completion: @escaping (Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("update edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { (response, result) in
                guard let response = response else {
                    print("update edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("update edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Create vertex: pass out jwt
    private func _createVertex(vertex: Vertex, jwt: String, completion: @escaping (Result<(Vertex, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cvReq()
        request.vertex = vertex
        request.jwt = jwt
    
        print("create vertex request json: \n", (try? request.jsonString()) ?? "")

        do {
            try client.cv(request, completion: { (response, result) in
                guard let response = response else {
                    print("Create vertex has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }

                print("Create vertex response: \n", (try? response.jsonString()) ?? "")

                if response.code == 0 {
                    completion(.success((response.vertex, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            })
        } catch {
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
}

//MARK: - Transform functions
extension AiTmed {
    func transform(args: SendOPTCodeArgs, completion: (Result<Edge, AiTmedError>) -> Void) {
        guard Validator.phoneNumber(args.phoneNumber),
            let name = [AiTmedNameKey.phoneNumber: args.phoneNumber].toJSON() else {
                completion(.failure(.unkown))
                return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.sendOPTCode
        edge.name = name
        completion(.success(edge))
    }
    
    func transform(args: CreateUserArgs, completion: (Result<(Vertex, Key), AiTmedError>) -> Void) {
        guard Validator.password(args.password),
            Validator.phoneNumber(args.phoneNumber) else {
                completion(.failure(.unkown))
                return
        }
        
        guard let keyPair = e.generateAKey(),
            let esk = e.generateESKey(from: keyPair.secretKey, using: args.password) else {
                completion(.failure(.unkown))
                return
        }
        
        var vertex = Vertex()
        vertex.type = AiTmedType.createUser
        vertex.tage = args.code
        vertex.uid = args.phoneNumber
        vertex.pk = keyPair.publicKey.toData()
        vertex.esk = esk.toData()
        completion(.success((vertex, keyPair.secretKey)))
    }
    
    func transform(args: LoginArgs, completion: (Result<(Edge, Credential), AiTmedError>) -> Void) {
        //Valid parameter
        guard Validator.password(args.password),
                Validator.phoneNumber(args.phoneNumber) else {
            completion(.failure(.unkown))
            return
        }
        
        //Is new device?
        guard var credential = c != nil ? c : Credential(phoneNumber: args.phoneNumber) else {
            completion(.failure(.credentialFailed(.credentialRequired)))
            return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.login
        edge.stime = Int64(Date().timeIntervalSince1970)
        edge.bvid = credential.userId
        
        //Is logged in?
        if let _ = credential.sk {
            completion(.success((edge, credential)))
        } else if let sk = e.generateSk(from: credential.esk, using: args.password) { //Is password correct?
            credential.sk = sk
            completion(.success((edge, credential)))
        } else {
            completion(.failure(.credentialFailed(.passwordFailed)))
        }
    }
    
    func transform(args: RetrieveCredentialArgs, completion: (Result<Edge, AiTmedError>) -> Void) {
        guard Validator.phoneNumber(args.phoneNumber),
            let name = [AiTmedNameKey.phoneNumber: args.phoneNumber, AiTmedNameKey.OPTCode: args.code].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.retrieveCredential
        edge.name = name
        completion(.success(edge))
    }
    
    func transform(args: RetrieveNotebooksArgs, completion: (Result<RetrieveEdgeArgs, AiTmedError>) -> Void) {
        guard let c = c, c.status == .login else {
            completion(.failure(.credentialFailed(.signinRequired)))
            return
        }
        
        completion(.success(args))
    }
    
    func transform(args: CreateOrUpdateNotebookArgs, completion: (Result<Edge, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.title: args.title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        guard let c = c, c.status == .login else {
            completion(.failure(.credentialFailed(.signinRequired)))
            return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.notebook
        edge.name = name
        
        if args.isEncrypt {
            guard let besak = e.generateXESAK(sendSecretKey: c.sk!, recvPublicKey: c.pk).0 else {
                completion(.failure(.credentialFailed(.signinRequired)))
                return
            }
            edge.besak = besak.toData()
        }
        
        completion(.success(edge))
    }
}
