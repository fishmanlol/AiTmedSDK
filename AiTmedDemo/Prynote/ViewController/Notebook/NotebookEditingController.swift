//
//  NotebookEditingController.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/29/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

protocol NotebookEditingControllerDelegate: class {
    func notebookEditingControllerDidTappedDeleteButton(_ vc: NotebookEditingController, notebook: Notebook)
    func notebookEditingControllerDidTappedSaveButton(_ vc: NotebookEditingController, notebook: Notebook, newTitle: String)
}

class NotebookEditingController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    weak var delegate: NotebookEditingControllerDelegate?
    weak var saveItem: UIBarButtonItem?
    var notebook: Notebook! {
        didSet {
            initialSaveItemAndNameTextField()
        }
    }
    
    override func viewDidLoad() {
        setUp()
    }
    
    //MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Actions
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        if sender.text == nil || sender.text!.isEmpty {
            saveItem?.isEnabled = false
        } else {
            saveItem?.isEnabled = true
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.notebookEditingControllerDidTappedDeleteButton(self, notebook: notebook)
    }
    
    @objc func didCancelItemTapped() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didSaveItemTapped(sender: UIBarButtonItem) {
        dismiss(animated: true) {
            let newTitle = self.nameTextField.text ?? ""
            self.delegate?.notebookEditingControllerDidTappedSaveButton(self, notebook: self.notebook, newTitle: newTitle)
        }
    }
    
    //MARK: - Private 
    private func setUp() {
        navigationItem.title = "Rename"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelItemTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSaveItemTapped))
        saveItem = navigationItem.rightBarButtonItem
        view.backgroundColor = UIColor.groupTableViewBackground
        
        initialSaveItemAndNameTextField()
    }
    
    private func initialSaveItemAndNameTextField() {
        if let notebook = notebook, let nameTextField = nameTextField {
            nameTextField.text = notebook.title
            saveItem?.isEnabled = !notebook.title.isEmpty
        }
    }
}
