//
//  NotebookListController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/13/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class NotebookListController: UIViewController {
    weak var tableView: UITableView!
    
    var selectedIndex: Int = 0
    var action: ((Notebook) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    @objc func didCancelItemTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didDoneItemTapped() {
        let notebook = Storage.default.notebooks[selectedIndex]
        dismiss(animated: true) {
            self.action?(notebook)
        }
    }
    
    
    
    private func setUp() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotebookListCell.self, forCellReuseIdentifier: Constant.Identifier.NOTEBOOKLISTCELL)
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        navigationItem.title = "Select notebook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneItemTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelItemTapped))
    }
    
    func displayEditingController(with mode: NotebookEditingController.Mode) {
        let editingController = NotebookEditingController(mode: mode)
        editingController.delegate = self
        let navigation = UINavigationController(rootViewController: editingController)
        present(navigation, animated: true) {
            self.isEditing = false
        }
    }
}

extension NotebookListController: NotebookEditingControllerDelegate {
    func notebookEditingControllerDidCreateSuccess(_ vc: NotebookEditingController, notebook: Notebook) {
        DispatchQueue.main.async {
            guard let index = Storage.default.notebooks.firstIndex(where: { $0 === notebook }) else { return }
            self.selectedIndex = index
            self.tableView.reloadData()
        }
    }
}

extension NotebookListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Storage.default.notebooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Identifier.NOTEBOOKLISTCELL, for: indexPath) as! NotebookListCell
        configure(cell, with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NotebookListHeader(delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return tableView.bounds.height
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return EmptyFooterView(datasource: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    private func configure(_ cell: NotebookListCell, with indexPath: IndexPath) {
        let notebook = Storage.default.notebooks[indexPath.row]
        cell.titleLabel?.text = notebook.title
        if indexPath.row == selectedIndex {
            cell.fixedImageView?.image = R.image.check()
        } else {
            if notebook.isEncrypt {
                cell.fixedImageView.image = R.image.lock()
            } else {
                cell.fixedImageView?.image = R.image.folder()
            }
        }
    }
}

extension NotebookListController: EmptyFooterViewDatasource {
    func title(forEmptyFooter footer: EmptyFooterView!) -> NSAttributedString? {
        return NSAttributedString(string: "No notebook", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 27, weight: .medium)])
    }
}

extension NotebookListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedIndex = selectedIndex
        selectedIndex = indexPath.row
        tableView.reloadRows(at: [IndexPath(row: oldSelectedIndex, section: 0), indexPath], with: .none)
    }
}

extension NotebookListController: NotebookListHeaderDelegate {
    func headerDidTapAddButton(_ header: NotebookListHeader) {
        displayEditingController(with: .create)
    }
    
    var titleForHeader: NSAttributedString {
        return NSAttributedString(string: "Notebooks", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 27, weight: .medium)])
    }
}

@objc protocol NotebookListHeaderDelegate: AnyObject {
    @objc func headerDidTapAddButton(_ header: NotebookListHeader)
}

class NotebookListHeader: UIView {
    weak var addButton: UIButton!
    unowned var delegate: NotebookListHeaderDelegate
    
    init(delegate: NotebookListHeaderDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setUp() {
        let addButton = UIButton(type: .system)
        addButton.setContentHuggingPriority(.required, for: .horizontal)
        addButton.setImage(R.image.add_circle(), for: .normal)
        addButton.addTarget(delegate, action: #selector(NotebookListHeaderDelegate.headerDidTapAddButton), for: .touchUpInside)
        self.addButton = addButton
        addSubview(addButton)
        
        addButton.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
        }
    }
}

class NotebookListCell: UITableViewCell {
    weak var fixedImageView: UIImageView!
    weak var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setUp() {
        selectionStyle = .none
        
        let fixedImageView = UIImageView()
        fixedImageView.contentMode = .scaleAspectFit
        self.fixedImageView = fixedImageView
        contentView.addSubview(fixedImageView)
        
        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        contentView.addSubview(titleLabel)
        
        fixedImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(fixedImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
    }
}
