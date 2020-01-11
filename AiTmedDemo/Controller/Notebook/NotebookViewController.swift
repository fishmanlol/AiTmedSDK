//
//  NotebookViewController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

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
    }
    
    @objc func didTapAdd() {
        displayEditingController(with: .create)
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReloadIfNeeded(indexPath(of: .all))
        asyncReloadIfNeeded(indexPath(of: .single(notebook)))
    }
}
