//
//  NotebookViewController+EditingControllerDelegate.swift
//  AiTmedDemo
//
//  Created by tongyi on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension NotebookViewController: NotebookEditingControllerDelegate {
    func notebookEditingControllerDidCreateSuccess(_ vc: NotebookEditingController, notebook: Notebook) {
        guard let index = Storage.default.notebooks.firstIndex(where: { $0 === notebook }) else { return }
        
        asyncInsert(IndexPath(row: index, section: 1))
        asyncReload(IndexPath(row: 0, section: 0))
    }
    
    func notebookEditingControllerDidEditSuccess(_ vc: NotebookEditingController, notebook: Notebook) {
        guard let index = Storage.default.notebooks.firstIndex(where: { $0 === notebook }) else { return }
        
        asyncReload(IndexPath(row: index, section: 1))
    }
}
