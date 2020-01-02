//
//  NotebookViewController.swift
//  Prynote2
//
//  Created by tongyi on 12/10/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit
import SnapKit

class NotebookViewController: UITableViewController {
    
    //MARK: - Property
    var open = true
    var stateCoordinator: StateCoordinator?
    unowned var storage: Storage
    
    //MARK: - Initialization
    init(_ storage: Storage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        storage.addDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Override
    override var isEditing: Bool {
        didSet {
            handleEditing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    //MARK: - Action
    @objc func didPullToRefreshing(refreshControl: UIRefreshControl) {
        print("Refreshing...")
        storage.loadNotebooks()
    }
    
    @objc func didTapSetting() {
        
    }
    
    @objc func didTapAdd() {
        displayInputAlert(title: "Title of notebook", msg: nil) { (title) in
            guard !title.isEmpty else {
                self.displayAlert(title: "Title should not be empty", msg: nil, action: nil)
                return
            }
            self.addNotebook(at: IndexPath(row: 0, section: 1), with: title)
        }
    }
    
    deinit {
        storage.removeDelegate(self)
    }
}

extension NotebookViewController: StorageDelegate {
    func storageDidLoadAllNotes(storage: Storage, success: Bool, error: AiTmedError?) {
        self.reloadRows([IndexPath(row: 0, section: 0)], with: .automatic)
        if !success {
            self.displayAlert(title: "Error", msg: error.debugDescription)
        }
    }
    
    func storageDidLoadNotebooks(storage: Storage, success: Bool, error: AiTmedError?) {
        DispatchQueue.main.async {
            if !success {
                self.displayAlert(title: "Error", msg: error.debugDescription)
                return
            }
            
            if self.tableView.refreshControl?.isRefreshing == true {
                self.tableView.refreshControl?.endRefreshing()
            }
            self.tableView.reloadData()
        }
    }
    
    func storageDidAddNotebook(storage: Storage, succcess: Bool, error: AiTmedError?, notebook: Notebook?) {
        if !succcess {
            
        }
    }
}

//MARK: - UIViewController extenison
extension UIViewController {
    
}
