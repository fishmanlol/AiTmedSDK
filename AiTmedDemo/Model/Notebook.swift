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
    var isReady = true
    
    init(_ _notebook: AiTmed._Notebook) {
        self.id = _notebook.id
        self.title = _notebook.title
        self.isEncrypt = _notebook.isEncrypt
        self.ctime = _notebook.ctime
        self.mtime = _notebook.mtime
    }
    
    func addNote(title: String, content: Data, completion: @escaping (Result<Note, PrynoteError>) -> Void) {
        AiTmed.addNote(folderID: id, title: title, content: content, isEncrypt: isEncrypt) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let _note):
                let note = Note(id: _note.id, notebook: strongSelf, isEncrypt: _note.isEncrypt, title: _note.title, content: _note.content, isBroken: _note.isBroken, mtime: _note.mtime, ctime: _note.ctime)
                strongSelf.notes.insert(note, at: 0)
                NotificationCenter.default.post(name: .didAddNote, object: self, userInfo: nil)
                completion(.success(note))
            }
        }
    }
    
    func retrieveNotes(completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        self.isReady = false
        AiTmed.retrieveNotes(notebookID: id) { (result) in
            self.isReady = true
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
                NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
            case .success(let _notes):
                let notes = _notes.map {
                    Note(id: $0.id, notebook: self, isEncrypt: $0.isEncrypt, title: $0.title, content: $0.content, isBroken: $0.isBroken, mtime: $0.mtime, ctime: $0.ctime)
                }
                self.notes = notes
                NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
                completion(.success(()))
            }
        }
    }
    
    func update(title: String, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.updateNotebook(id: id, title: title, isEncrypt: isEncrypt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let _notebook):
                self.title = _notebook.title
                self.mtime = _notebook.mtime
                self.title = _notebook.title
                
                Storage.default.sortByTitle()
                NotificationCenter.default.post(name: .didUpdateNotebook, object: self)
                completion(.success(()))
            }
        }
    }
}
