//
//  Note.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import UIKit
import AiTmedSDK1

class Note {
    var id: Data
    unowned var notebook: Notebook
    var title: String = ""
    var rawContent: Data = Data()
    var ctime: Date = Date()
    var mtime: Date = Date()
    var isBroken = false
    var isEncrypt = false
    var displayContent: String {
        return String(data: rawContent, encoding: .utf8) ?? ""
    }
    
    init(id: Data, notebook: Notebook, isEncrypt: Bool, title: String = "", content: Data = Data(), isBroken: Bool = false, mtime: Date = Date(), ctime: Date = Date()) {
        self.isEncrypt = isEncrypt
        self.id = id
        self.notebook = notebook
        self.title = title
        self.rawContent = content
        self.isBroken = isBroken
        self.mtime = mtime
        self.ctime = ctime
    }
    
    func update(title: String, content: Data, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.updateNote(id: id, notebookID: notebook.id, title: title, content: content, isEncrypt: isEncrypt) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let _note):
                strongSelf.id = _note.id
                strongSelf.title = _note.title
                strongSelf.rawContent = _note.content
                strongSelf.ctime = _note.ctime
                strongSelf.mtime = _note.mtime
                strongSelf.isEncrypt = _note.isEncrypt
                strongSelf.isBroken = _note.isBroken
                NotificationCenter.default.post(name: .didUpdateNote, object: self)
                completion(.success(()))
            }
        }
    }
    
    func delete(completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.deleteNote(id: id) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                NotificationCenter.default.post(name: .didRemoveNote, object: self)
                completion(.success(()))
            }
        }
    }
}
