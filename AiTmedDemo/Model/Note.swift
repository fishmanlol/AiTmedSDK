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

struct Note {
    var id: Data
    var notebook: Notebook
    var title: String = ""
    var rawContent: Data = Data()
    var ctime: Date = Date()
    var mtime: Date = Date()
    var isBroken = false
    var mime: MimeType
    var displayContent: String {
        if mime == .plain {
            return String(data: rawContent, encoding: .utf8) ?? ""
        } else {
            return String(data: rawContent, encoding: .utf8) ?? ""
        }
    }
    
    init(id: Data, notebook: Notebook, title: String = "", content: Data = Data(), isBroken: Bool = false, mtime: Date = Date(), ctime: Date = Date(), mime: MimeType) {
        self.id = id
        self.notebook = notebook
        self.title = title
        self.rawContent = content
        self.isBroken = isBroken
        self.mtime = mtime
        self.ctime = ctime
        self.mime = mime
    }
    
    func update(title: String? = nil, content: Data? = nil, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.updateNote(id: id, notebookID: notebook.id, title: title, content: content) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
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
                completion(.success(()))
            }
        }
    }
}
