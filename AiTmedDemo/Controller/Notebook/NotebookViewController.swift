//
//  NotebookViewController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK1

class NotebookViewController: UITableViewController {
    let stateCoordinator: StateCoordinator
    var open: Bool = true
    
    init(_ stateCoordinator: StateCoordinator) {
        self.stateCoordinator = stateCoordinator
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
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
        Storage.default.retrieveNotebooks { [weak self] (result) in
            guard let weakSelf = self else { return }
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
            
            switch result {
            case .failure(let error):
                weakSelf.displayAutoDismissAlert(msg: error.message)
            case .success(_):
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func didTapSetting() {
        print(#function)
        AiTmed.deleteUser { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                print("delete success!")
            }
        }
    }
    
    @objc func didTapAdd() {
        displayEditingController(with: .create)
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReloadIfNeeded(indexPath(of: .all))
        asyncReloadIfNeeded(indexPath(of: .single(notebook)))
    }
    
    @objc func didRemoveNote(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReloadIfNeeded(indexPath(of: .all))
        asyncReloadIfNeeded(indexPath(of: .single(notebook)))
    }
}

