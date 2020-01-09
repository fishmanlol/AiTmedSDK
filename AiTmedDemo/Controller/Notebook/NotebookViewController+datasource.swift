//
//  NotebookViewController+datasource.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

extension NotebookViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return open ? getCountOfNotebooks() : 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTEBOOKCELL) as! NotebookCell
        let group: NotesGroup
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            group = .all
        case IndexPath(row: 1, section: 0):
            group = .sharedWithMe
        default:
            group = .single(notebook(at: indexPath))
        }
        configure(cell, with: group)
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
