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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func notebookEditingControllerDidEditSuccess(_ vc: NotebookEditingController, notebook: Notebook) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
