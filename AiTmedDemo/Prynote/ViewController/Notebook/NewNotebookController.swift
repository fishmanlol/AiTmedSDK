//
//  NewNotebookController.swift
//  AiTmedDemo
//
//  Created by tongyi on 1/1/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

protocol NewNotebookControllerDelegate: class {
    func didTapSaveItem(_ vc: UIViewController, title: String, completion: @escaping (Result<Void, AiTmedError>) -> Void)
}

class NewNotebookController: UIViewController {
    
    //MARK: - Property
    lazy var saveItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSaveItemTapped))
    lazy var indicatorItem: UIBarButtonItem = UIBarButtonItem(customView: UIActivityIndicatorView(style: .gray))
    weak var titleTextField: UITextField!
    weak var delegate: NewNotebookControllerDelegate?
    var isLoading: Bool = false {
        didSet {
            updateRightItem()
        }
    }
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    //MARK: - Actions
    @objc func didCancelItemTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didSaveItemTapped() {
        isLoading = true
        let title = titleTextField.text ?? ""
        delegate?.didTapSaveItem(self, title: title, completion: { (result) in
            self.isLoading = false
            switch result {
            case .failure(_):
                self.displayAutoDismissAlert(msg: "Create notebook failed")
            case .success(_):
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @objc func didTitleChanged(textField: UITextField) {
        if textField.text?.isEmpty == false {
            saveItem.isEnabled = true
        } else {
            saveItem.isEnabled = false
        }
    }
    
    //MARK: - Helper
    private func updateRightItem() {
        if isLoading {
            navigationItem.rightBarButtonItem = indicatorItem
        } else {
            navigationItem.rightBarButtonItem = saveItem
        }
    }
    
    private func setUp() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelItemTapped))
        navigationItem.rightBarButtonItem = saveItem
        
        let container = UIView()
        view.addSubview(container)
        
        let titleTextField = UITextField()
        titleTextField.addTarget(self, action: #selector(didTitleChanged), for: .editingChanged)
        titleTextField.font = UIFont.systemFont(ofSize: 36)
        self.titleTextField = titleTextField
        container.addSubview(titleTextField)
        
        let separator = UIView()
        separator.backgroundColor = .gray
        view.addSubview(separator)
        
        separator.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(48)
            make.top.equalToSuperview().inset(200)
            make.height.equalTo(1)
        }
        
        container.snp.makeConstraints { (make) in
            make.left.right.equalTo(separator)
            make.bottom.equalTo(separator.snp.top)
            make.top.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(60)
        }
    }
}
