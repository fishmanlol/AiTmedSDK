//
//  NotesViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NotesViewController: UITableViewController {
    unowned var storage: Storage
    var notesGroup: NotesGroup
    var stateCoordinator: StateCoordinator?
    var notes: [Note] {
        return getNotes(in: notesGroup)
    }
    var isLoading: Bool {
        return getIsLoading()
    }
    
    private lazy var spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private lazy var noteCountItem: UIBarButtonItem = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return UIBarButtonItem(customView: label)
    }()
    private lazy var writeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didWriteItemTapped))
    
    //MARK: - Initializations
    init(storage: Storage, notesGroup: NotesGroup) {
        self.storage = storage
        self.notesGroup = notesGroup
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
        switch notesGroup {
        case .all:
            displayNotebookList()
        case .single(let notebook):
            storage.addNoteAtLocal(title: "New Note", content: "", in: notebook) { (note) in
                if let index = notes.firstIndex(of: note) {
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    tableView.endUpdates()
                    stateCoordinator?.select(note)
                }
            }
        case .sharedWithMe:
            break
        }
        
//        displayInputAlert(title: "Title of notebook", msg: nil) { (title) in
//            guard !title.isEmpty else {
//                self.displayAlert(title: "Title should not be empty", msg: nil, action: nil)
//                return
//            }
//            if self.storage.numberOfNotebooks() == 0 {//When no notebook in storage
//                self.addNotebook(at: IndexPath(row: 0, section: 0), with: title) { (result) in
//                    switch result {
//                    case .failure(_):
//                        self.displayAutoDismissAlert(msg: "Create notebook failed")
//                    case .success(let notebook):
//                        let note = Note(title: "", content: "", notebook: notebook)
//                        self.stateCoordinator?.select(note)
//                        print(note)
//                    }
//                }
//            }
//        }
//        stateCoordinator?.select(note, in: notebook)
    }
    
    @objc func didLoadAllNotes(no: Notification) {
//        dismissWaitingView()
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    
    @objc func didLoadAllNotesInNotebook(no: Notification) {
//        dismissWaitingView()
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
    }
    
    @objc func didAddNote(no: Notification) {
//        guard let note = no.userInfo?[Constant.UserInfoKey.note] as? Note else { return }
//        notes.insert(note, at: 0)
//        dismissWaitingView()
//        DispatchQueue.main.async {
//            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//            self.updateToolbar()
//            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
////            self.stateCoordinator?.select(self.notes.first, in: self.notebook)
//        }
    }
    
    @objc func didRemoveNote(no: Notification) {
//        guard let note = no.userInfo?[Constant.UserInfoKey.note] as? Note,
//                let index = notes.firstIndex(of: note) else { return }
//        notes.remove(at: index)
//        dismissWaitingView()
//        DispatchQueue.main.async {
////            self.stateCoordinator?.select(self.notes.first, in: self.notebook)
//            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//            self.updateToolbar()
//            if !self.notes.isEmpty {
//                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
//            }
//        }
    }
    
    private func setUp() {
        //tableview
        tableView.register(UINib(resource: R.nib.noteCell), forCellReuseIdentifier: Constant.Identifier.NOTECELL)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIImageView(image: R.image.paper_light())
        tableView.allowsMultipleSelection = false
        
        //navigation
        navigationItem.title = notesGroup.title
        
        //Observers
//        NotificationCenter.default
//            .addObserver(self, selector: #selector(didLoadAllNotes), name: .didLoadAllNotes, object: storage)
//        NotificationCenter.default.addObserver(self, selector: #selector(didLoadAllNotesInNotebook), name: .didLoadAllNotesInNotebook, object: _notebook)
//        NotificationCenter.default.addObserver(self, selector: #selector(didAddNote), name: .didAddNote, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveNote), name: .didRemoveNote, object: nil)
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
                label.text = "\(notes.count) notes"
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateToolbar()
    }
}

extension NotesViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let waitingView = WaitingView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        if isLoading {
            waitingView.startAnimating()
            waitingView.setMsg("Loading")
        } else {
            waitingView.stopAnimating()
            waitingView.setMsg("No Notes")
        }
        return waitingView
    }
}
