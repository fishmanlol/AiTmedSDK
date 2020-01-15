//
//  MasterController+StateCoordinatorDelegate.swift
//  AiTmedDemo
//
//  Created by tongyi on 1/12/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

extension MasterController: StateCoordinatorDelegate {
    func didSelectedNotesGroup(_ notesGroup: NotesGroup) {
        let navigation = primaryNav(rootSplit)
        navigation.pushViewController(freshNotesController(with: notesGroup), animated: true)
    }
    
    func willCreateNote(in notebook: Notebook) {
        let editor = freshEditor(notebook: notebook, mode: .create)
        let navigation = primaryNav(rootSplit)
        
        if isHorizontallyRegular {
            rootSplit.viewControllers = [navigation, editor]
        } else {
            navigation.pushViewController(editor, animated: true)
        }
    }
}
