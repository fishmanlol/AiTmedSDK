//
//  Note.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation

class Note {
    var id: Data?
    var title: String = ""
    var content: String = ""
    var isLoading = false
    var date = Date()
    unowned var notebook: Notebook
    
    init(title: String, content: String, notebook: Notebook) {
        self.notebook = notebook
        self.title = title
        self.content = content
    }
    
//    
//    static func mock(in notebook: Notebook) -> Note {
//        return Note(title: "", content: "", notebook: notebook)
//    }
//    
//    func load(completion: @escaping () -> Void) {
//        isLoading = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.title = "Aaaaa"
//            self.content = "Bbbbbbbb"
//            self.isLoading = false
//            completion()
//        }
//    }
}

extension Note: Equatable {
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}
