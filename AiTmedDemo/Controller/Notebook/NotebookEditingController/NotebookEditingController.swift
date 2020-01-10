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
    weak var contentView: UIView!
    weak var scrollView: UIScrollView!
    
    lazy var cancelItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelItem))
    lazy var doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneItem))
    lazy var indicatorItem: UIBarButtonItem = {
        let indictor = UIActivityIndicatorView(style: .gray)
        indictor.hidesWhenStopped = true
        indictor.startAnimating()
        return UIBarButtonItem(customView: indictor)
    }()
    
    lazy var lockButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapLockButton), for: .touchUpInside)
        return button
    }()
    
    private var mode: Mode
    private var notebook: Notebook!
    private var keyboard = Keyboard()
    private var isLoading = false {
        didSet {
            didLoadingChange()
        }
    }
    private var isEncrypt: Bool = false {
        didSet {
            didEncryptionChange()
        }
    }
    //MARK: - Action
    @objc func didTapActionButton(button: UIButton) {
        button.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.endAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didTapCancelItem() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDoneItem() {
        view.endEditing(true)
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }
    }
    
    @objc func didTapLockButton() {
        isEncrypt = !isEncrypt
    }
    
    @objc func didTextFieldChange(textField: UITextField) {
        let text = textField.text ?? ""
        doneItem.isEnabled = !text.isEmpty
    }
    
    //MARK: - Initialization
    init(mode: Mode) {
        self.mode = mode
        if case Mode.update(let notebook) = mode {
            self.notebook = notebook
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        layoutSubviews()
        addObservers()
    }
    
    //MARK: - Helper
    private func didLoadingChange() {
        if isLoading {
            navigationController?.froze()
            navigationItem.setRightBarButton(indicatorItem, animated: true)
        } else {
            navigationController?.defroze()
            navigationItem.setRightBarButton(doneItem, animated: true)
        }
    }
    
    private func didEncryptionChange() {
        if isEncrypt {
            navigationItem.prompt = "Encrypted"
            lockButton.setImage(R.image.lock(), for: .normal)
        } else {
            navigationItem.prompt = "Public"
            lockButton.setImage(R.image.unlock(), for: .normal)
        }
    }
    
    private func addObservers() {
        keyboard.observeKeyboardWillShow { [weak self] (info) in
            self?.adjustPositionIfNeeded(info.endRect)
        }
        
        keyboard.observeKeyboardWillHide { [weak self] (info) in
            self?.restorePostionIfNeeded(info.endRect)
        }
    }
    
    private func adjustPositionIfNeeded(_ rect: CGRect) {
        let gap: CGFloat = 30
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollRectToVisible(separator.frame.offsetBy(dx: 0, dy: gap), animated: true)
    }
    
    private func restorePostionIfNeeded(_ rect: CGRect) {
        scrollView.contentInset = UIEdgeInsets()
    }
    
    private func setUp() {
        view.backgroundColor = .white
        isEncrypt = false
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = doneItem
        navigationItem.titleView = lockButton
        
        if case Mode.update(let notebook) = mode {
            lockButton.isEnabled = false
            doneItem.isEnabled = !notebook.title.isEmpty
        } else {
            doneItem.isEnabled = false
            lockButton.isEnabled = true
        }
        
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentInsetAdjustmentBehavior = .never
        scrollView = v
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView = contentView
        scrollView.addSubview(contentView)
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        self.separator = separator
        contentView.addSubview(separator)
        
        let textField = UITextField()
        textField.delegate = self
        textField.addTarget(self, action: #selector(didTextFieldChange), for: .editingChanged)
        textField.placeholder = "Notebook Name"
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
    }
    
    private func layoutSubviews() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
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
    }
    
    //MARK: - Enum mode
    enum Mode {
        case create
        case update(Notebook)
    }
}

extension NotebookEditingController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
