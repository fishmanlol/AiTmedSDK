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
//        deleteDoc(id: id, completion: completion)
    }
    
    public static func retrieveNotes(notebookID: Data, completion: @escaping (Result<[_Note], AiTmedError>) -> Void) {
        completion(.success([]))
    }

    //MARK: - Notebook
    public static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        guard let args = CreateEdgeArgs(type: type, name: name, isEncrypt: isEncrypt) else {
            completion(.failure(.unkown))
            return
        }
        
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
                    edge.ctime, mtime: edge.mtime)
                completion(.success(_notebook))
            }
        }
    }
    
    public static func updateNotebook(id: Data, title: String, completion: @escaping (Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        let args = UpdateEdgeArgs(id: id, type: type, name: name)
        AiTmed.updateEdge(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                var title = ""
                if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                    title = t
                }
                let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime:
                    edge.ctime, mtime: edge.mtime)
                completion(.success(_notebook))
            }
        }
    }
    
    public static func deleteNotebook(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        deleteEdge(args: DeleteArgs(id: id), completion: completion)
    }
    
    public static func retrieveNotebooks(maxCount: Int32? = nil, completion: @escaping (Result<[_Notebook], AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        let args = RetrieveArgs(ids: [], type: type, maxCount: maxCount)
        
        retrieveEdges(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edges):
                var _notebooks: [_Notebook] = []
                for edge in edges {
                    var title = ""
                    if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                        title = t
                    }
                    let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime: edge.ctime, mtime: edge.mtime)
                    _notebooks.append(_notebook)
                }
                completion(.success(_notebooks))
            }
        }
    }
}
