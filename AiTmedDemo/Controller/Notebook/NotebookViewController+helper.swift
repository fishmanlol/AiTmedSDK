//
//  NotebookViewController+helper.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

extension NotebookViewController {
    func getCountOfNotebooks() -> Int {
        return Storage.default.notebooks.count
    }
    
    func notebook(at indexPath: IndexPath) -> Notebook {
        return Storage.default.notebooks[indexPath.row]
    }
    
    func configure(_ cell: NotebookCell, with group: NotesGroup) {
        switch group {
        case .all:
            cell.titleLabel.text = "All Notes"
            
        case .single(let notebook):
            cell.titleLabel.text = "\(notebook.title)"
        default:
            cell.titleLabel.text = "Shared With Me"
        }
        
        cell.notesCountLabel.text = "\(group.count)"
        
        cell.isLoading = !group.isReady
    }
    
    func indexPath(of group: NotesGroup) -> IndexPath {
        switch group {
        case .all:
            return IndexPath(row: 0, section: 0)
        case .sharedWithMe:
            return IndexPath(row: 1, section: 0)
        case .single(let notebook):
            return IndexPath(row: Storage.default.notebooks.firstIndex(where: { $0 === notebook })!, section: 1)
        }
    }
    
    func setUp() {
        //add background view
        let backgroundView = UIImageView(image: R.image.paper_light())
        backgroundView.contentMode = .scaleToFill
        
        //tableview
        tableView.register(UINib(resource: R.nib.notebookCell), forCellReuseIdentifier: Constant.Identifier.NOTEBOOKCELL)
        tableView.register(UINib(resource: R.nib.notebookHeader), forHeaderFooterViewReuseIdentifier: Constant.Identifier.NOTEBOOKHEADER)
        tableView.separatorStyle = .none
        tableView.backgroundView = backgroundView
        tableView.allowsSelectionDuringEditing = true
        
        //navigation item
        navigationItem.title = "Notebooks"
        let userItem = UIBarButtonItem(image: R.image.user(), style: .plain, target: self, action: #selector(didTapSetting))
        let editItem = editButtonItem
        navigationItem.setLeftBarButton(userItem, animated: false)
        navigationItem.setRightBarButton(editItem, animated: false)
        
        //toolbar item
        let addItem = UIBarButtonItem(title: "New Notebook", style: .done, target: self, action: #selector(didTapAdd))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems([spaceItem, spaceItem, spaceItem, spaceItem, addItem], animated: false)
        
        //refreshing
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: Constant.Strings.refreshingText)
        refreshControl.addTarget(self, action: #selector(didPullToRefreshing), for: .valueChanged)
        self.refreshControl = refreshControl
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadAllNotesInNotebook), name: .didLoadAllNotesInNotebook, object: nil)
    }
    
    func asyncReload(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func displayEditingController(with mode: NotebookEditingController.Mode) {
        let editingController = NotebookEditingController(mode: mode)
        let navigation = UINavigationController(rootViewController: editingController)
        present(navigation, animated: true, completion: nil)
    }
}

