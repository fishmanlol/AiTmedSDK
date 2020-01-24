//
//  NotesViewController+.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

extension NotesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = group.notes[indexPath.row]
        stateCoordinator.select(note)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        return group.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTECELL, for: indexPath) as! NoteCell
        let note = group.notes[indexPath.row]
        
        configure(cell, with: note)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return tableView.bounds.height
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footer = EmptyFooterView(datasource: self)
            return footer
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    private func configure(_ cell: NoteCell, with note: Note) {
        cell.titleLabel.text = note.title
        cell.detailLabel.text = note.displayContent
        cell.dateLabel.text = note.mtime.formattedDate
    }
}
