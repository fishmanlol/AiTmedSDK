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
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        if !notebook(at: indexPath).isReady {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            guard indexPath.section == 1 else { return }
            
            displayEditingController(with: .update(notebook(at: indexPath)))
        } else {
            
        }
        
        return
        if isEditing && indexPath.section == 1 {//display notebook edit page
//            guard let editingNav = R.storyboard.main().instantiateViewController(withIdentifier: Constant.Identifier.NOTEBOOKEDITINGNAVIGATION) as? UINavigationController,
//                let editingController = editingNav.viewControllers.first as? NotebookEditingController,
//                let notebook = storage.notebook(at: indexPath.row) else { return }
//            editingController.notebook = notebook
//            editingController.delegate = self
//            present(editingNav, animated: true, completion: nil)
            
            return
        }
        
        if indexPath == IndexPath(row: 0, section: 0) {//all notes
//            stateCoordinator?.select(.all)
            return
        }
        
        if indexPath == IndexPath(row: 1, section: 0) {//shared notes
//            stateCoordinator?.select(.sharedWithMe)
            return
        }
        
        //notebooks
//        if let notebook = storage.notebook(at: indexPath.row) {
//            stateCoordinator?.select(.single(notebook))
//        }
        
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
