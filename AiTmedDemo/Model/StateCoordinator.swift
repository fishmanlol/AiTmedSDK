//
//  StateCoordinator.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation

protocol StateCoordinatorDelegate: class {
    func didSelectedNotesGroup(_ notesGroup: NotesGroup)
    func didSelectedNote(_ note: Note?)
    func willCreateNote(in notebook: Notebook)
    func didCreate(_ note: Note, in notebook: Notebook)
    func didDelete(_ note: Note)
}

extension StateCoordinatorDelegate {
    func didSelectedNotesGroup(_ notesGroup: NotesGroup) {}
    func didSelectedNote(_ note: Note) {}
    func willCreateNote(in notebook: Notebook) {}
    func didCreate(_ note: Note, in notebook: Notebook) {}
    func didDelete(_ note: Note) {}
}

class StateCoordinator {
    func select(_ notesGroup: NotesGroup) {
        delegate?.didSelectedNotesGroup(notesGroup)
    }
    
    func select(_ note: Note?) {
        delegate?.didSelectedNote(note)
    }
    
    func willCreateNote(in notebook: Notebook) {
        delegate?.willCreateNote(in: notebook)
    }
    
    func didCreate(_ note: Note, in notebook: Notebook) {
        delegate?.didCreate(note, in: notebook)
    }
    
    func delete(_ note: Note) {
        delegate?.didDelete(note)
    }
    
    weak var delegate: StateCoordinatorDelegate?
}
