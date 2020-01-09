//
//  AiTmed+Prynote.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Note
    public static func addNote(title: String, content: Data, isEncrypt: Bool, completion: @escaping (Result<_Note, AiTmedError>) -> Void) {
        
    }
    
    public static func updateNote(id: Data, notebookID: Data, title: String?, content: Data?, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        
    }
    
    public static func deleteNote(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        deleteDoc(id: id, completion: completion)
    }
    
    public static func retrieveNotes(notebookID: Data, completion: @escaping (Result<[_Note], AiTmedError>) -> Void) {
        
    }
    
    //MARK: - Notebook
    public static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        guard let c = shared.c, let sk = c.sk, let keyPair = shared.e.generateXESAK(sendSecretKey: sk, recvPublicKey: c.pk) else {
            completion(.failure(.unkown))
            return
        }
        
        let (besak, eesak) = keyPair
        
        let args = CreateEdgeArgs(type: type, name: name, bvid: nil, besak: besak.toData(), eesak: eesak.toData())
        AiTmed.createEdge(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                var title = ""
                if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                    title = t
                }
                let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime:
                    Date(timeIntervalSince1970: TimeInterval(edge.ctime)), mtime: Date(timeIntervalSince1970: TimeInterval(edge.mtime)))
                completion(.success(_notebook))
            }
        }
    }
    
    public static func updateNotebook(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        
    }
    
    public static func deleteNotebook(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        
    }
    
    public static func retrieveNotebooks(completion: @escaping (Result<[_Notebook], AiTmedError>) -> Void) {
        
    }
    
    public struct _Note {
        public var id: Data
        public var title: String
        public var content: Data
        public var ctime: Date = Date()
        public var mtime: Date = Date()
        public var isBroken = false
    }
    
    public struct _Notebook {
        public var id: Data
        public var title: String
        public var isEncrypt: Bool
        public var ctime: Date = Date()
        public var mtime: Date = Date()
    }
    
    public struct _Appointment {
    
    }
}
