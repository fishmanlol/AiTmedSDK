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
    static func loadNotebooks(ids: [Data], completion: @escaping (Result<[Notebook], AiTmedError>) -> Void) {
        let args = AiTmedSDK.RetrieveNotebooksArgs(ids: ids, maxCount: nil)
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
    
    static func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<Data, AiTmedError>) -> Void) {
        let args = AiTmedSDK.CreateNotebookArgs(title: title, isEncrypt: isEncrypt)
        AiTmed.Prynote.createNoteBook(args: args) { (result) in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(let nb):
                completion(.success(nb.id))
            }
        }
    }
    
    static func updateNotebook(id: Data, title: String? = nil, isEncrypt: Bool? = nil, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        let args = AiTmedSDK.UpdateNotebookArgs(id: id, title: title, isEncrypt: isEncrypt, type: nil)
        AiTmed.Prynote.updateNotebook(args: args) { (result) in
            switch result {
            case .failure(_):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    static func remove(_ ids: [Data], completion: @escaping (Result<Void, AiTmedSDK.AiTmedError>) -> Void) {
        AiTmed.delete(ids: ids, completion: completion)
    }
    
    static func addNote(note: Note, in notebook: Notebook, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        if let folderID = notebook.id {
            let args = CreateDocumentArgs(title: note.title, content: note.content.toData() ?? Data(), isEncrypt: notebook.isEncrypt, folderID: folderID)
            AiTmed.Prynote.createDocument(args: args) { (result) in
                completion(.success(()))
                print("create")
            }
        } else {
            completion(.failure(.unkown))
        }
    }
    
    static func loadNotes(in notebookID: Data, completion: @escaping (Result<[Document], AiTmedError>) -> Void) {
//        AiTmed.load
    }
    
    
    
//    static func loadFiles(in id: Data, completion: @escaping (Result<[File], AiTmedError>) -> Void) {
//        AiTmed.retreiveFiles(args: RetrieveFileArgs(folderID: id)) { (result) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let files):
//                completion(.success(files))
//            }
//        }
//    }
}
