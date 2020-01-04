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
        stateCoordinator?.select(notes[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 0 : notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTECELL, for: indexPath) as! NoteCell
        let note = notes[indexPath.row]
        
        configure(cell, with: note)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    private func configure(_ cell: NoteCell, with note: Note) {
        cell.titleLabel.text = note.title
        cell.detailLabel.text = note.content
        cell.dateLabel.text = note.date.formattedDate
    }
}
