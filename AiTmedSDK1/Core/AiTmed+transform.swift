//
//  AiTmed+transform.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    ///call back
    func transform(args: SendOPTCodeArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
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
    
    ///sync
    func transform(args: SendOPTCodeArgs) -> Result<Edge, AiTmedError> {
        guard Validator.phoneNumber(args.phoneNumber),
            let name = [AiTmedNameKey.phoneNumber: args.phoneNumber].toJSON() else {
                return .failure(.unkown)
        }
        
        var edge = Edge()
        edge.type = AiTmedType.sendOPTCode
        edge.name = name
        return .success(edge)
    }
    
    func transform(args: CreateUserArgs, completion: (Swift.Result<(Vertex, Key), AiTmedError>) -> Void) {
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
        vertex.type = AiTmedType.user
        vertex.tage = args.code
        vertex.uid = args.phoneNumber
        vertex.pk = keyPair.publicKey.toData()
        vertex.esk = esk.toData()
        completion(.success((vertex, keyPair.secretKey)))
    }
    
    func transform(args: LoginArgs, completion: (Swift.Result<(Edge, Credential), AiTmedError>) -> Void) {
        //Valid parameter
        guard Validator.password(args.password),
            Validator.phoneNumber(args.phoneNumber) else {
                completion(.failure(.unkown))
                return
        }
        
        //Is new device?
        guard var credential = c != nil ? c : Credential(phoneNumber: args.phoneNumber) else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
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
            completion(.failure(.credentialFailed(.credentialNeeded)))
        }
    }
    
    func transform(args: RetrieveCredentialArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
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
    
//    func transform(args: RetrieveNotebooksArgs, completion: (Swift.Result<RetrieveEdgeArgs, AiTmedError>) -> Void) {
//        guard let c = c, c.status == .login else {
//            completion(.failure(.credentialFailed(.credentialNeeded)))
//            return
//        }
//        
//        completion(.success(args))
//    }
    
    func transform(args: CreateNotebookArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.title: args.title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        guard let c = c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.notebook
        edge.name = name
        
        if args.isEncrypt {
            let (besak, eesak) = e.generateXESAK(sendSecretKey: c.sk!, recvPublicKey: c.pk)!
            let b = besak
            let e = eesak
            
            edge.besak = b.toData()
            edge.eesak = e.toData()
        }
        
        completion(.success(edge))
    }
    
    func transform(args: UpdateNotebookArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        guard let c = c, c.status == .login else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        var edge = Edge()
        edge.type = AiTmedType.notebook
        
        if let title = args.title {
            guard let name = [AiTmedNameKey.title: title].toJSON() else {
                completion(.failure(.unkown))
                return
            }
            
            edge.name = name
        }
        
        if let isEncrypt = args.isEncrypt {
            if isEncrypt {
                guard let besak = e.generateXESAK(sendSecretKey: c.sk!, recvPublicKey: c.pk)?.0 else {
                    completion(.failure(.credentialFailed(.credentialNeeded)))
                    return
                }
                edge.besak = besak.toData()
            } else {
                edge.besak = Data()
            }
        }
        
        completion(.success(edge))
    }
    
    
}
