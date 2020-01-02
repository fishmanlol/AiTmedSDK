//
//  Notebook.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation

class Notebook {
    var id: Data?
    var title: String
    var isEncrypt: Bool = true
    var notes: [Note] = []
    var date = Date()
    var isLoading = false
    
    init(title: String, id: Data, isEncrypt: Bool) {
        self.title = title
        self.id = id
        self.isEncrypt = isEncrypt
    }
    
    init(title: String) {
        self.title = title
    }
    
    func numberOfNotes() -> Int {
        return notes.count
    }
//
//    func load(completion: @escaping () -> Void) {
//        isLoading = true
//        let group = DispatchGroup()
//        notes.forEach { (note) in
//            group.enter()
//            note.load(completion: {
//                group.leave()
//            })
//        }
//        group.notify(queue: DispatchQueue.main) {
//            self.isLoading = false
//            completion()
//            NotificationCenter.default.post(name: .didLoadAllNotesInNotebook, object: self)
//        }
//    }
//
//    func numberOfNotes() -> Int {
//        return notes.count
//    }
}
