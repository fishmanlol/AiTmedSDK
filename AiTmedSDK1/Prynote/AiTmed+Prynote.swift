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
        guard let name = [AiTmedNameKey.title: title].toJSON(),
                let args = CreateEdgeArgs(type: type, name: name, isEncrypt: isEncrypt) else {
            completion(.failure(.unkown))
            return
        }
        
        AiTmed.createEdge(args: args)
        .done { (edge) in
            guard let dict = edge.name.toJSONDict(), let title = dict["title"] as? String else {
                completion(.failure(.unkown))
                return
            }
            
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime:
                edge.ctime, mtime: edge.mtime)
            completion(.success(_notebook))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    public static func updateNotebook(id: Data, title: String, isEncrypt: Bool, completion: @escaping (Result<_Notebook, AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        guard let name = [AiTmedNameKey.title: title].toJSON() else {
            completion(.failure(.unkown))
            return
        }
        
        let args = UpdateEdgeArgs(id: id, type: type, name: name, isEncrypt: isEncrypt)
        
        AiTmed.updateEdge(args: args)
        .done { (edge) in
            guard let dict = edge.name.toJSONDict(), let title = dict["title"] as? String else {
                completion(.failure(.unkown))
                return
            }
            
            let _notebook = _Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty, ctime:
                edge.ctime, mtime: edge.mtime)
            completion(.success(_notebook))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
    
    public static func deleteNotebook(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        deleteEdge(args: DeleteArgs(id: id), completion: completion)
    }
    
    public static func retrieveNotebooks(maxCount: Int32? = nil, completion: @escaping (Result<[_Notebook], AiTmedError>) -> Void) {
        let type = AiTmedType.notebook
        let args = RetrieveArgs(ids: [], type: type, maxCount: maxCount)
        
        AiTmed.retrieveEdges(args: args)
        .done { (edges) in
            let _notebooks: [_Notebook] = edges.map {
                var title = ""
                if let dict = $0.name.toJSONDict(), let t = dict["title"] as? String {
                    title = t
                }
                return _Notebook(id: $0.id, title: title, isEncrypt: !$0.besak.isEmpty, ctime: $0.ctime, mtime: $0.mtime)
            }
            completion(.success(_notebooks))
        }.catch { (error) in
            completion(.failure(error.toAiTmedError()))
        }
    }
}
