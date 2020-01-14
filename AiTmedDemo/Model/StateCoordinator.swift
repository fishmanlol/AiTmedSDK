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
}

class StateCoordinator {
    func select(_ notesGroup: NotesGroup) {
        delegate?.didSelectedNotesGroup(notesGroup)
    }
    
    weak var delegate: StateCoordinatorDelegate?
}
