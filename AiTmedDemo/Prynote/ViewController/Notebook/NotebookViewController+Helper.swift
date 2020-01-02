//
//  Notebook+Helper.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//
import UIKit

extension NotebookViewController {
    //MARK: - Add
    func addNotebook(at indexPath: IndexPath, with title: String) {
        let notebook = Notebook(title: title)
        self.storage.addNotebookAtLocal(notebook: notebook, at: indexPath.row) { (index) in
            self.storage.addNotebookAtRemote(notebook: notebook) { (result) in
                notebook.isLoading = false
                switch result {
                case .failure(_):
                    self.displayAutoDismissAlert(msg: "Create notebook failed")
                    self.storage.removeNotebookAtLocal(notebook: notebook) { (deleteIndex) in
                        self.deleteRows([IndexPath(row: deleteIndex, section: 1)], with: .automatic)
                    }
                case .success(_):
                    self.reloadRows([IndexPath(row: index, section: 1)], with: .automatic)
                }
            }
            
            notebook.isLoading = true
            self.insertRows([IndexPath(row: index, section: 1)], with: .automatic)
        }
    }
    
    //MARK: - Remove
    func removeNotebook(at indexPath: IndexPath) {
        if let notebook = storage.notebook(at: indexPath.row) {
            notebook.isLoading = true
            self.reloadRows([indexPath], with: .automatic)
            storage.removeNotebookAtRemote(notebook: notebook) { (result) in
                notebook.isLoading = false
                switch result {
                case .failure(_):
                    self.displayAutoDismissAlert(msg: "Remove notebook failed")
                    self.reloadRows([indexPath], with: .automatic)
                case .success(_):
                    self.storage.removeNotebookAtLocal(notebook: notebook) { (index) in
                        self.deleteRows([indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    //MARK: - Update
    func updateNotebook(at indexPath: IndexPath, with title: String) {
        if let notebook = storage.notebook(at: indexPath.row) {
            notebook.isLoading = true
            self.reloadRows([indexPath], with: .automatic)
            
            storage.updateNotebookAtRemote(notebook: notebook, title: title) { (result) in
                notebook.isLoading = false
                switch result {
                case .failure(_):
                    self.displayAutoDismissAlert(msg: "Update notebook failed")
                    self.reloadRows([indexPath], with: .automatic)
                case .success(_):
                    self.storage.updateNotebookAtLocal(notebook: notebook, title: title) { (updateIndex) in
                        self.reloadRows([IndexPath(row: updateIndex, section: 1)], with: .automatic)
                    }
                }
            }
        }
    }
    
    //MARK: - crud rows
    func deleteRows(_ indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if open {
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: indexPaths, with: animation)
            }
        }
    }
    
    func insertRows(_ indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if open {
            DispatchQueue.main.async {
                self.tableView.insertRows(at: indexPaths, with: animation)
            }
        }
    }
    
    func reloadRows(_ indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        if open {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: indexPaths, with: animation)
            }
        }
    }
    
    //MARK: - Private
    func pullToRefreshing() {
        DispatchQueue.main.async {
            let y = self.tableView.contentOffset.y - 1
            let offset = CGPoint(x: self.tableView.contentOffset.x, y: y)
            self.tableView.setContentOffset(offset, animated: true)
            self.refreshControl?.beginRefreshing()
            self.refreshControl?.sendActions(for: .valueChanged)
        }
    }
        
    func handleEditing() {
        print("123")
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
    }
}
