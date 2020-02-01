//
//  NotesViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

class NotesViewController: UITableViewController {
    var group: NotesGroup
    var stateCoordinator: StateCoordinator
    
    private lazy var spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private lazy var noteCountItem: UIBarButtonItem = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return UIBarButtonItem(customView: label)
    }()
    private lazy var writeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didWriteItemTapped))
    
    //MARK: - Initializations
    init(_ stateCoordinator: StateCoordinator, group: NotesGroup) {
        self.stateCoordinator = stateCoordinator
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateToolbar()
    }
    
    @objc func didWriteItemTapped() {
        switch group {
        case .all:
            displayNotebookList { [unowned self] notebook in
                self.stateCoordinator.willCreateNote(in: notebook)
            }
        case .single(let notebook):
            stateCoordinator.willCreateNote(in: notebook)
        default:
            displayAutoDismissAlert(msg: "Can not share with others")
        }
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didAddNote(no: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didUpdateNote(no: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    @objc func didRemoveNote(no: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setUp() {
        //tableview
        tableView.register(UINib(resource: R.nib.noteCell), forCellReuseIdentifier: Constant.Identifier.NOTECELL)
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: R.image.paper_light())
        tableView.allowsMultipleSelection = false
        
        //navigation
        navigationItem.title = group.title
        
        //Observers
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadAllNotesInNotebook), name: .didLoadAllNotesInNotebook, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didAddNote), name: .didAddNote, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateNote), name: .didUpdateNote, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveNote), name: .didRemoveNote, object: nil)
    }
    
    private func updateToolbar() {
        if let split = splitViewController {
            if !split.isCollapsed, split.viewControllers.count > 1,
               let nav = split.viewControllers[1] as? UINavigationController,
                nav.topViewController is EditorViewController {//hide add button
                toolbarItems = [spaceItem, noteCountItem, spaceItem]
            } else {
                toolbarItems = [spaceItem, noteCountItem, spaceItem, writeItem]
            }

            if let label = noteCountItem.customView as? UILabel {
                label.text = "\(group.count) notes"
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateToolbar()
    }
    
}

extension NotesViewController: EmptyFooterViewDatasource {
    func title(forEmptyFooter footer: EmptyFooterView!) -> NSAttributedString? {
        return NSAttributedString(string: "You don't have any notes now", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 27, weight: .medium)])
    }
    
    func buttonTitle(forEmptyFooter footer: EmptyFooterView!) -> NSAttributedString? {
        return NSAttributedString(string: "New note", attributes: [NSAttributedString.Key.foregroundColor: view.tintColor as Any, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    func emptyFooterViewDidButtonTapped(_ v: EmptyFooterView) {
        didWriteItemTapped()
    }
}
