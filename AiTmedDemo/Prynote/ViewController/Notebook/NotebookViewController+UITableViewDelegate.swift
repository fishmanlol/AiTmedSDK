//
//  NotebookViewController+UITableViewDelegate.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension NotebookViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete only one notebook at once
            if storage.isDeleting {
                displayAutoDismissAlert(msg: "You can not delete multiple notebooks at once")
                return
            }
            
            removeNotebook(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        if let notebook = storage.notebook(at: indexPath.row), notebook.isLoading {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let notebook = storage.notebook(at: indexPath.row), notebook.isLoading {
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing && indexPath.section == 1 {//display notebook edit page
            guard let editingNav = R.storyboard.main().instantiateViewController(withIdentifier: Constant.Identifier.NOTEBOOKEDITINGNAVIGATION) as? UINavigationController,
                let editingController = editingNav.viewControllers.first as? NotebookEditingController,
                let notebook = storage.notebook(at: indexPath.row) else { return }
            editingController.notebook = notebook
            editingController.delegate = self
            present(editingNav, animated: true, completion: nil)
            
            return
        }
        
        if indexPath == IndexPath(row: 0, section: 0) {//all notes
            stateCoordinator?.select(.all)
            return
        }
        
        if indexPath == IndexPath(row: 1, section: 0) {//shared notes
            stateCoordinator?.select(.sharedWithMe)
            return
        }
        
        //notebooks
        if let notebook = storage.notebook(at: indexPath.row) {
            stateCoordinator?.select(.single(notebook))
        }
        
//        switch indexPath {
//        case IndexPath(row: 0, section: 0):
//            let notesViewController = NotesViewController()
//            notesViewController.storage = storage
//            notesViewController.notes = storage.allNotes()
//            notesViewController.stateCoordinator = stateCoordinator
//            navigationController?.pushViewController(notesViewController, animated: true)
//        case IndexPath(row: 1, section: 0):
//            navigationController?.pushViewController(SharedViewController(), animated: true)
//        default:
//            let notesViewController = NotesViewController()
//            let notebook = storage.notebooks[indexPath.row]
//            notesViewController.storage = storage
//            notesViewController.notes = storage.notes(in: notebook)
//            notesViewController._notebook = notebook
//            notesViewController.stateCoordinator = stateCoordinator
//            navigationController?.pushViewController(notesViewController, animated: true)
//        }
        
    }
    

}

extension NotebookViewController: NotebookHeaderDelegate {
    func notebookHeaderDidOpen(_ header: NotebookHeader, in section: Int) {
        var insertIndexPaths: [IndexPath] = []
        for row in 0..<storage.numberOfNotebooks() {
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
