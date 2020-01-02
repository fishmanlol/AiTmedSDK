//
//  NotesGroup.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation

enum NotesGroup {
    case single(Notebook)
    case all
    case sharedWithMe
    
    var title: String {
        switch self {
        case .all:
            return "Notes"
        case .sharedWithMe:
            return "Shared With Me"
        case .single(let notebook):
            return notebook.title
        }
    }
}

//class NotesGroup {
//    var notes: [Note]
//    var notebook: Notebook?
//    let type: GroupType
//
//    init(type: GroupType, notebooks: [Notebook]) {
//        self.type = type
//        switch type {
//        case .single:
//            guard notebooks.count == 1 else { fatalError("Single group type must contains 1 notebook") }
//            self.notes = notebooks[0].notes
//        case .all:
//            self.notes = notebooks.flatMap { $0.notes }
//        case .sharedWithMe:
//            self.notes = []
//        }
//    }
//
//
//}
