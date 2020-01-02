//
//  EditorViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

protocol EditorViewControllerDelegate: class {
    func didChangeNote(_ editor: EditorViewController, note: Note)
    func willSaveNote(_ editor: EditorViewController, note: Note)
    func didSaveNote(_ editor: EditorViewController, note: Note, success: Bool)
}

extension EditorViewControllerDelegate {
    func didChangeNote(_ editor: EditorViewController, note: Note) {}
    func willSaveNote(_ editor: EditorViewController, note: Note) {}
    func didSaveNote(_ editor: EditorViewController, note: Note, success: Bool) {}
}

class EditorViewController: UIViewController {
    weak var backgroudImageView: UIImageView!
    weak var titleTextField: UITextField!
    weak var contentTextView: UITextView!
    
    lazy var doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneItemTapped))
    lazy var shareToItem = UIBarButtonItem(image: R.image.share_to(), style: .done, target: self, action: #selector(didShareToItemTapped))
    lazy var indicatorItem = UIBarButtonItem(customView: UIActivityIndicatorView(style: .gray))
    
    let note: Note
    unowned var storage: Storage
    weak var delegate: EditorViewControllerDelegate?
    var timer: Timer?
    var isLoading = false {
        didSet {
            didChangeLoadingState()
        }
    }
    var isKeyboardOnScreen: Bool {
        return titleTextField.isFirstResponder || contentTextView.isFirstResponder
    }
    
    init(note: Note, storage: Storage) {
        self.note = note
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleTextField.addUnderLineIfNeeded()
    }
    
    //MARK: - Action
    @objc func didTrashItemTapped() {
        displayWaitingView(msg: "Removing...")
//        note.notebook.remove(note)
    }
    
    @objc func didCameraItemTapped() {
        
    }
    
    @objc func didComposeItemTapped() {
//        notebook.add(note)
    }
    
    @objc func didShareToItemTapped() {
        
    }
    
    @objc func didDoneItemTapped() {
        view.endEditing(true)
        if let id = note.id {
            
        } else {
            delegate?.willSaveNote(self, note: note)
            storage.addNoteAtRemote(note) { [weak self] (result) in
                guard let weakSelf = self else { return }
                weakSelf.isLoading = true
                switch result {
                case .failure(let error):
                    weakSelf.displayAutoDismissAlert(msg: "Add note failed")
                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: false)
                case .success(_):
                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: true)
                    if weakSelf.traitCollection.horizontalSizeClass == .compact {
                        weakSelf.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(no: Notification) {
        //navigation item
        navigationItem.setRightBarButtonItems([doneItem, shareToItem], animated: false)
    }
    
    @objc func keyboardWillHide(no: Notification) {
        //navigation item
        navigationItem.setRightBarButtonItems([shareToItem], animated: false)
    }
    
    @objc func didChangeTitle(_ textField: UITextField) {
        let title = textField.text ?? ""
        note.title = title
        didChangeNote()
    }
    
    private func didChangeNote() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.delegate?.didChangeNote(self, note: self.note)
        })
    }
    
    private func didChangeLoadingState() {
        if isLoading {
            navigationItem.rightBarButtonItems = [shareToItem, indicatorItem]
        } else if isKeyboardOnScreen {
            navigationItem.rightBarButtonItems = [shareToItem, doneItem]
        } else {
            navigationItem.rightBarButtonItems = [shareToItem]
        }
    }
    
    private func setUp() {
        let backgroudImageView = UIImageView(image: R.image.paper_light())
        self.backgroudImageView = backgroudImageView
        view.addSubview(backgroudImageView)
        backgroudImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let titleTextField = UITextField()
        titleTextField.delegate = self
        titleTextField.placeholder = "Title..."
        titleTextField.text = note.title
        titleTextField.addTarget(self, action: #selector(didChangeTitle), for: .editingChanged)
        self.titleTextField = titleTextField
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        
        let contentTextView = UITextView()
        contentTextView.text = note.content
        contentTextView.delegate = self
        contentTextView.backgroundColor = .clear
        self.contentTextView = contentTextView
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
        }
        
        
        //toolbar
        let trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTrashItemTapped))
        let cameraItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didCameraItemTapped))
        let composeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didComposeItemTapped))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [trashItem, spaceItem, cameraItem, spaceItem, composeItem]
        
        
        //navigation bar
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.setRightBarButton(shareToItem, animated: false)
        
        //observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        let trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTrashItemTapped))
        let cameraItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didCameraItemTapped))
        let composeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didComposeItemTapped))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
        toolbarItems = [trashItem, spaceItem, cameraItem, spaceItem, composeItem]
    }
}

extension EditorViewController: UINavigationControllerDelegate {
    
}

extension EditorViewController: UITextFieldDelegate {

}

extension EditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let content = textView.text
        note.content = content ?? ""
        didChangeNote()
    }
}
