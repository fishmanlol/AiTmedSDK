//
//  ChooseNotebooksController.swift
//  AiTmedDemo
//
//  Created by tongyi on 1/1/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class NotebookListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var tableView: UITableView!
    weak var addButton: UIButton!
    unowned var storage: Storage
    let cellID = "NOTEBOOKLISTCELL"
    var onComplete: ((Notebook) -> Void)?
    
    //MARK: - Initialization
    init(storage: Storage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    //MARK: - Action
    @objc func didCloseItemTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storage.numberOfNotebooks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let notebook = storage.notebook(at: indexPath.row)!
        configure(cell, with: notebook)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notebook = storage.notebook(at: indexPath.row)!
        dismiss(animated: true) {
            self.onComplete?(notebook)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: - Private
extension NotebookListController {
    private func setUp() {
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        view.addSubview(tableView)
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("New notebook", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = view.tintColor
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 6
        self.addButton = addButton
        view.addSubview(addButton)
        
        addButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(addButton.snp.bottom).offset(8)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.close(), style: .plain, target: self, action: #selector(didCloseItemTapped))
        navigationItem.title = "Notebooks"
    }
    
    private func configure(_ cell: UITableViewCell, with notebook: Notebook) {
        cell.imageView?.image = R.image.notebook()
        cell.textLabel?.text = notebook.title
    }
}
