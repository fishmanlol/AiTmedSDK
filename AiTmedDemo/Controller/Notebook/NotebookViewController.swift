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
        super.init(nibName: nil, bundle: nil)
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
        print("Refreshing...")
    }
    
    @objc func didTapSetting() {
        print(#function)
    }
    
    @objc func didTapAdd() {
        displayEditingController(with: .create)
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
        guard let notebook = no.object as? Notebook else { return }
        
        asyncReload(indexPath(of: .all))
        asyncReload(indexPath(of: .single(notebook)))
    }
}
