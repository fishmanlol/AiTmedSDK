//
//  NotebookViewController+Header.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

extension NotebookViewController: NotebookHeaderDelegate {
    func notebookHeaderDidOpen(_ header: NotebookHeader, in section: Int) {
        var insertIndexPaths: [IndexPath] = []
        for row in 0..<getCountOfNotebooks() {
            insertIndexPaths.append(IndexPath(row: row, section: section))
        }
        
        open = true
        tableView.beginUpdates()
        tableView.insertRows(at: insertIndexPaths, with: .fade)
        tableView.endUpdates()
    }
    
    func notebookHeaderDidClose(_ header: NotebookHeader, in section: Int) {
        var deleteIndexPaths: [IndexPath] = []
        for row in 0..<tableView.numberOfRows(inSection: section) {
            deleteIndexPaths.append(IndexPath(row: row, section: section))
        }
        
        open = false
        tableView.beginUpdates()
        tableView.deleteRows(at: deleteIndexPaths, with: .fade)
        tableView.endUpdates()
    }
}
