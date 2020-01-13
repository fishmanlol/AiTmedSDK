////
////  NotesViewController+Helper.swift
////  AiTmedDemo
////
////  Created by tongyi on 12/30/19.
////  Copyright © 2019 Yi Tong. All rights reserved.
////
//
//import UIKit
//
//extension NotesViewController {
//    func getNotes(in notesGroup: NotesGroup) -> [Note] {
//        switch notesGroup {
//        case .single(let notebook):
//            return storage.notes(in: notebook)
//        case .sharedWithMe:
//            return storage.sharedWithMeNotes()
//        case .all:
//            return storage.allNotes()
//        }
//    }
//    
//    func getIsLoading() -> Bool {
//        if case let NotesGroup.single(notebook) = notesGroup {
//            if notebook.isLoading {
//                return true
//            }
//        } else { //all notes and shared
//            if storage.isLoadingAllNotes {
//                return true
//            }
//        }
//        
//        return false
//    }
//    
//    //MARK: - Add
//    func addNotebook(at indexPath: IndexPath, with title: String, completion: @escaping (Result<Notebook, PrynoteError>) -> Void) {
//          let notebook = Notebook(title: title)
//          self.storage.addNotebookAtLocal(notebook: notebook, at: indexPath.row) { (index) in
//              self.storage.addNotebookAtRemote(notebook: notebook) { (result) in
//                  notebook.isLoading = false
//                  switch result {
//                  case .failure(let error):
//                      self.displayAutoDismissAlert(msg: "Create notebook failed")
//                      self.storage.removeNotebookAtLocal(notebook: notebook) { (_) in
//                        completion(.failure(error))
//                      }
//                  case .success(_):
//                    completion(.success(notebook))
//                  }
//              }
//              
//              notebook.isLoading = true
//          }
//      }
//    
//    func displayNotebookList() {
//        let listController = NotebookListController(storage: storage)
//        let listControllerNav = UINavigationController(rootViewController: listController)
//        listController.onComplete = { [weak self] notebook in
//            self?.storage.addNoteAtLocal(title: "New Note", content: "", in: notebook) { (note) in
//                if let index = self?.notes.firstIndex(of: note) {
//                    self?.tableView.beginUpdates()
//                    self?.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                    self?.tableView.endUpdates()
//                    self?.stateCoordinator?.select(note)
//                }
//            }
//        }
//        present(listControllerNav, animated: true, completion: nil)
//    }
//}
