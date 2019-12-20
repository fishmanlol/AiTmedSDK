//
//  AiTmed.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation
import AiTmedSDK

class APIService {
    static func loadNotebooks(completion: @escaping (Result<[Notebook], AiTmedError>) -> Void) {
        let args = AiTmedSDK.RetrieveNotebooksArgs()
        AiTmed.Prynote.retrieveNotebooks(args: args) { result in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(let nbs):
                var notebooks: [Notebook] = []
                for nb in nbs {
                    notebooks.append(Notebook(title: nb.title, id: nb.id, isEncrypt: nb.isEncrypt))
                }
                completion(.success(notebooks))
            }
        }
    }
    
    static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
        let args = AiTmedSDK.CreateNotebookArgs(title: title, isEncrypt: isEncrypt)
        AiTmed.Prynote.createNoteBook(args: args) { (result) in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(let nb):
                let notebook = Notebook(title: nb.title, id: nb.id, isEncrypt: nb.isEncrypt)
                completion(.success(notebook))
            }
        }
    }
    
    static func updateNotebook(title: String? = nil, isEncrypt: Bool? = nil, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
        let args = AiTmedSDK.UpdateNotebookArgs(title: title, isEncrypt: isEncrypt, type: nil)
        AiTmed.Prynote.updateNotebook(args: args) { (result) in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(let nb):
                let notebook = Notebook(title: nb.title, id: nb.id, isEncrypt: nb.isEncrypt)
                completion(.success(notebook))
            }
        }
    }
    
    static func removeNotebook(_ notebooks: [Notebook], completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.delete(ids: notebooks.map({ $0.id })) { (result) in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    static func addNote(title: String, content: String, completion: @escaping (Result<Note, AiTmedError>) -> Void) {
        
    }
}
