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
            let nb = notebook(at: indexPath)
            displayAlert(title: "Delete", msg: "Do you want to delete '\(nb.title)'?", hasCancel: true, actionTitle: "Yes", style: .destructive) {
                WaitingView.scheduleDisplayOnWindow(delay: 0.5, msg: "Waiting...")
                Storage.default.deleteNotebook(notebook: nb) { (result) in
                    WaitingView.dismissOnWindow()
                    switch result {
                    case .failure(let error):
                        self.displayAutoDismissAlert(msg: "Delete notebook failed")
                    case .success(_):
                        self.asyncDeleteIfNeeded(indexPath)
                        self.asyncReloadIfNeeded(IndexPath(row: 0, section: 0))
                    }
                }
            }
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
            switch indexPath {
            case IndexPath(row: 0, section: 0):
                stateCoordinator.select(.all)
            case IndexPath(row: 1, section: 0):
                stateCoordinator.select(.sharedWithMe)
            default:
                let nb = notebook(at: indexPath)
                stateCoordinator.select(.single(nb))
            }
            
        }
    }
}
