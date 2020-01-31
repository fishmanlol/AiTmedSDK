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
            if navigation.topViewController is EditorViewController {
                let vcs = Array(navigation.viewControllers.dropLast()) + [freshEditor(notebook: notebook, mode: .create)]
                navigation.setViewControllers(vcs, animated: true)
            } else {
                navigation.pushViewController(editor, animated: true)
            }
        }
    }
    
    func didSelectedNote(_ note: Note?) {
        let navigation = primaryNav(rootSplit)
        if let n = note {
            let editor = freshEditor(notebook: n.notebook, mode: .update(n))
            
            if isHorizontallyRegular {
                rootSplit.viewControllers = [navigation, editor]
            } else {
                navigation.pushViewController(editor, animated: true)
            }
        } else {
            if isHorizontallyRegular {
                rootSplit.viewControllers = [navigation, freshPlaceholderViewController()]
            } else {
                if navigation.topViewController is EditorViewController {
                    navigation.popViewController(animated: true)
                }
            }
        }
        
    }
}
