//
//  Notebook.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK1

struct Notebook {
    var id: Data
    var title: String
    var isEncrypt: Bool = false
    var notes: [Note] = []
    var ctime: Date = Date()
    var mtime: Date = Date()
    
    init(id: Data, title: String, isEncrypt: Bool) {
        self.id = id
        self.title = title
    }
    
    func addNote(title: String, content: Data, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.addNote(title: title, content: content, isEncrypt: isEncrypt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    func retrieveNotes(completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        
    }
}
