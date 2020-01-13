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
    
    var isReady: Bool {
        switch self {
        case .all:
            return Storage.default.notebooks.allSatisfy { $0.isReady }
        case .single(let notebook):
            return notebook.isReady
        default:
            return true
        }
    }
    
    var count: Int {
        return notes.count
    }
    
    var notes: [Note] {
        switch self {
        case .all:
            return Storage.default.notebooks.flatMap { $0.notes }
        case .sharedWithMe:
            return []
        case .single(let notebook):
            return notebook.notes
        }
    }
    
    var title: String {
        switch self {
        case .all:
            return "All Notes"
        case .single(let notebook):
            return notebook.title
        default:
            return "Shared With Me"
        }
    }
}
