//
//  Note.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation
import AiTmedSDK

class Note {
    var id: Data?
    var title: String = ""
    var content: String = ""
    var isEncrypt: Bool = false
    var isLoading = false
    var date = Date()
    unowned var notebook: Notebook
    
    init(title: String, content: String, notebook: Notebook) {
        self.notebook = notebook
        self.title = title
        self.content = content
    }
    
    init(file: Document, notebook: Notebook) {
        self.id = file.id
        self.content = String(bytes: file.content ?? Data(), encoding: .utf8) ?? ""
        self.isEncrypt = file.isEncrypt
        self.title = file.title ?? ""
        self.notebook = notebook
    }
}

extension Note: Equatable {
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}
