//
//  NotebookViewController+NotebookEditingControllerDelegate.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension NotebookViewController: NotebookEditingControllerDelegate {
    func notebookEditingControllerDidTappedDeleteButton(_ vc: NotebookEditingController, notebook: Notebook) {
        if let index = storage.index(of: notebook) {
            removeNotebook(at: IndexPath(row: index, section: 1))
        }
    }
    
    func notebookEditingControllerDidTappedSaveButton(_ vc: NotebookEditingController, notebook: Notebook, newTitle: String) {
        if let index = storage.index(of: notebook) {
            updateNotebook(at: IndexPath(row: index, section: 1), with: newTitle)
        }
    }
}
