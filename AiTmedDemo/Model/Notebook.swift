//
//  Notebook.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK1

class Notebook {
    var id: Data
    var title: String
    var isEncrypt: Bool = false
    var notes: [Note] = []
    var ctime: Date = Date()
    var mtime: Date = Date()
    var isReady = false
    
    init(id: Data, title: String, isEncrypt: Bool) {
        self.id = id
        self.title = title
    }
    
    func addNote(title: String, content: Data, completion: @escaping (Result<Note, PrynoteError>) -> Void) {
        AiTmed.addNote(title: title, content: content, isEncrypt: isEncrypt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                fatalError()
//                completion(.success(Note()))
            }
        }
    }
    
    func retrieveNotes(completion: @escaping (Result<[Note], PrynoteError>) -> Void) {
        self.isReady = false
        AiTmed.retrieveNotes(notebookID: id) { (result) in
            self.isReady = true
            NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let _notes):
                let notes = _notes.map {
                    Note(id: $0.id, notebook: self, title: $0.title, content: $0.content, isBroken: $0.isBroken, mtime: $0.mtime, ctime: $0.ctime)
                }
                completion(.success(notes))
            }
        }
    }
    
    func update(title: String, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.updateNotebook(id: id) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    func delete(completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.deleteNotebook(id: id) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
}
