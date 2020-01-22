//
//  User.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import PromiseKit
import Foundation

extension AiTmed {
    //MARK: - Has credential
    public static func hasCredential(for phoneNumber: String) -> Bool {
        if let c = shared.c, c.phoneNumber == phoneNumber {
            return true
        } else if let _ = Credential(phoneNumber: phoneNumber) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - Retrieve credential
    public static func retrieveCredential(args: RetrieveCredentialArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.phoneNumber: args.phoneNumber, AiTmedNameKey.OPTCode: args.code].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        let arguments = CreateEdgeArgs(type: AiTmedType.retrieveCredential, name: name, isEncrypt: false)!
        
        firstly { () -> Promise<Edge> in
            createEdge(args: arguments)
        }.done({ (edge) in
            completion(.success(()))
        }).catch({ (error) in
            completion(.failure(error.toAiTmedError()))
        })
    }
    
    //MARK: - Log in
    public static func login(args: LoginArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        //Is new device?
        guard let c = Credential(phoneNumber: args.phoneNumber) else {
            completion(.failure(.credentialFailed(.credentialNeeded)))
            return
        }
        
        shared.c = c
        let arguments = CreateEdgeArgs(type: AiTmedType.login, name: "", isEncrypt: false, bvid: c.userId, evid: nil)!
        
        firstly { () -> Promise<Edge> in
            createEdge(args: arguments)
        }.done({ (edge) in
            completion(.success(()))
        }).catch({ (error) in
            completion(.failure(error.toAiTmedError()))
        })
    }
    
    //MARK: - Log out
    public static func logout() {
        shared.c?.sk = nil
    }
    
    //MARK: - Create user
    public static func createUser(args: CreateUserArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard Validator.password(args.password),
            Validator.phoneNumber(args.phoneNumber) else {
                completion(.failure(.unkown))
                return
        }
        
        guard let keyPair = shared.e.generateAKey(),
            let esk = shared.e.generateESKey(from: keyPair.secretKey, using: args.password)?.toData() else {
                completion(.failure(.unkown))
                return
        }
        
        let pk = keyPair.publicKey.toData()
        let sk = keyPair.secretKey.toData()
        let arguments = CreateVertexArgs(type: AiTmedType.user, tage: args.code, uid: args.phoneNumber, pk: pk, esk: esk, sk: sk)
        
        firstly { () -> Promise<Vertex> in
            createVertex(args: arguments)
        }.done { (edge) in
            completion(.success(()))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
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
    public static func sendOPTCode(args: SendOPTCodeArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
        guard let name = [AiTmedNameKey.phoneNumber: args.phoneNumber].toJSON(),
                let args = CreateEdgeArgs(type: AiTmedType.sendOPTCode, name: name, isEncrypt: false) else {
            completion(.failure(.unkown))
            return
        }
        
        firstly { () -> Promise<Edge> in
            createEdge(args: args)
        }.done { (edge) in
            completion(.success(()))
        }.catch { (error) in
            completion(Swift.Result.failure(error.toAiTmedError()))
        }
    }
}
