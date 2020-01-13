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
//    func didSelectedNote(_ note: Note?)
}

class StateCoordinator {
    func select(_ notesGroup: NotesGroup) {
        delegate?.didSelectedNotesGroup(notesGroup)
    }
//    func select(_ note: Note?) {
//        delegate?.didSelectedNote(note)
//    }
    
    weak var delegate: StateCoordinatorDelegate?
}
