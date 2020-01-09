//
//  NotebookEditingController.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit

class NotebookEditingController: UIViewController {
    //MARK: - Property
    weak var separator: UIView!
    weak var textField: UITextField!
    weak var actionButton: UIButton!
    weak var encryptSwitch: UISwitch!
    weak var contentView: UIView!
    
    private var mode: Mode
    private var notebook: Notebook!
    //MARK: - Action
    @objc func didTapActionButton(button: UIButton) {
        button.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.endAnimating()
            self.dismiss(animated: true, completion: nil)
        }
//        Storage.default.addNotebook(title: <#T##String#>, isEncrypt: <#T##Bool#>, completion: <#T##(Result<Notebook, AiTmedError>) -> Void#>)
    }
    
    @objc func closeItemTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Initialization
    init(mode: Mode) {
        self.mode = mode
        if case Mode.update(let notebook) = mode {
            self.notebook = notebook
        }
        fatalError()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    //MARK: - View lifecycle
    override func loadView() {
        view = UIScrollView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        layoutSubviews()
    }
    
    //MARK: - Helper
    private func setUp() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.close(), style: .plain, target: self, action: #selector(closeItemTapped))
        if case Mode.create = mode {
            navigationItem.title = "New Notebook"
        } else {
            navigationItem.title = "Edit"
        }
        
        let contentView = UIView()
        self.contentView = contentView
        view.addSubview(contentView)
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        self.separator = separator
        contentView.addSubview(separator)
        
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        self.textField = textField
        contentView.addSubview(textField)
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitleColor(.white, for: .normal)
        if case .create = mode {
            actionButton.backgroundColor = view.tintColor
            actionButton.setTitle("Create", for: .normal)
        } else {
            actionButton.setTitle("Delete", for: .normal)
            actionButton.backgroundColor = .red
        }
        self.actionButton = actionButton
        contentView.addSubview(actionButton)
        
        let encryptSwitch = UISwitch()
        self.encryptSwitch = encryptSwitch
        contentView.addSubview(encryptSwitch)
    }
    
    private func layoutSubviews() {
        contentView.snp.makeConstraints { (make) in
            make.edges.width.height.equalToSuperview()
        }
        
        separator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.67)
            make.centerY.equalToSuperview().inset(40)
            make.height.equalTo(0.5)
        }
        
        textField.snp.makeConstraints { (make) in
            make.left.right.equalTo(separator)
            make.bottom.equalTo(separator.snp.top).offset(-16)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(40)
        }
        
//        encryptSwitch.snp.makeConstraints(<#T##closure: (ConstraintMaker) -> Void##(ConstraintMaker) -> Void#>)
        
        
    }
    
    //MARK: - Enum mode
    enum Mode {
        case create
        case update(Notebook)
    }
}
