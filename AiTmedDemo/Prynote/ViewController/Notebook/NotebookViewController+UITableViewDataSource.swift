//
//  NotebookViewController+DataSource.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

extension NotebookViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            if storage.isLoadingAllNotebooks {
                return 0
            } else {
                return open ? storage.numberOfNotebooks() : 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTEBOOKCELL) as! NotebookCell
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell.titleLabel?.text = "All Notes"
            cell.notesCountLabel?.text = "\(storage.numberOfAllNotes())"
            cell.isLoading = storage.isLoadingAllNotes
        case IndexPath(row: 1, section: 0):
            cell.titleLabel?.text = "Shared With Me"
            cell.notesCountLabel?.text = "0"
            cell.isLoading = false
        default:
            let notebook = storage.notebook(at: indexPath.row)
            cell.titleLabel?.text = notebook?.title
            cell.notesCountLabel?.text = "\(notebook?.numberOfNotes() ?? 0)"
            cell.isLoading = notebook?.isLoading ?? true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 56
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else { return nil }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constant.Identifier.NOTEBOOKHEADER) as! NotebookHeader
        header.configure(title: "All Notebooks", section: section, delegate: self)
        return header
    }
}
