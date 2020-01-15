//
//  EditorViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
    weak var backgroudImageView: UIImageView!
    weak var titleTextField: UITextField!
    weak var contentTextView: UITextView!
    
    lazy var doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneItemTapped))
    lazy var shareToItem = UIBarButtonItem(image: R.image.share_to(), style: .done, target: self, action: #selector(didShareToItemTapped))
    lazy var indicatorItem = UIBarButtonItem(customView: UIActivityIndicatorView(style: .gray))
    lazy var trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTrashItemTapped))
    lazy var cameraItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didCameraItemTapped))
    lazy var composeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didComposeItemTapped))
    lazy var spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let notebook: Notebook
    let mode: Mode
    let stateCoordinator: StateCoordinator
    
    enum Mode {
        case create
        case update(Note)
    }
    
    var isLoading = false {
        didSet {
            DispatchQueue.main.async {
                self.didChangeLoadingState()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
//        self.view = UIScrollView(frame: UIScreen.main.bounds)
    }
    
    init(_ stateCoordinator: StateCoordinator, notebook: Notebook, mode: Mode) {
        self.stateCoordinator = stateCoordinator
        self.notebook = notebook
        self.mode = mode
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
//        displayWaitingView(msg: "Removing...")
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
//        isLoading = true
//        if let id = note.id {
//            delegate?.willSaveNote(self, note: note)
//            storage.updateNoteAtRemote(note) { [weak self] (result) in
//                guard let weakSelf = self else { return }
//                weakSelf.isLoading = false
//
//                switch result {
//                case .failure(let error):
//                    weakSelf.displayAutoDismissAlert(msg: "update note failed")
//                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: false)
//                case .success(_):
//                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: true)
//                    if weakSelf.traitCollection.horizontalSizeClass == .compact {
//                        weakSelf.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
//        } else {
//            delegate?.willSaveNote(self, note: note)
//            storage.addNoteAtRemote(note) { [weak self] (result) in
//                guard let weakSelf = self else { return }
//                weakSelf.isLoading = false
//                switch result {
//                case .failure(let error):
//                    weakSelf.displayAutoDismissAlert(msg: "Add note failed")
//                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: false)
//                case .success(_):
//                    weakSelf.delegate?.didSaveNote(weakSelf, note: weakSelf.note, success: true)
//                    if weakSelf.traitCollection.horizontalSizeClass == .compact {
//                        weakSelf.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
//        }
    }
    
    private func didChangeLoadingState() {
//        if isLoading {
//            navigationItem.rightBarButtonItems = [shareToItem, indicatorItem]
//        } else if isKeyboardOnScreen {
//            navigationItem.rightBarButtonItems = [shareToItem, doneItem]
//        } else {
//            navigationItem.rightBarButtonItems = [shareToItem]
//        }
    }
    
    private func setUp() {
//        let contentView = UIView()
//        view.addSubview(contentView)
//        contentView.snp.makeConstraints { (make) in
//            make.edges.width.height.equalToSuperview()
//        }
        
        let backgroudImageView = UIImageView(image: R.image.paper_light())
        self.backgroudImageView = backgroudImageView
        view.addSubview(backgroudImageView)
        backgroudImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let titleTextField = UITextField()
        titleTextField.placeholder = "Title..."
        self.titleTextField = titleTextField
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.top.equalToSuperview().inset(topBarHeight + 8)
        }
        
        let contentTextView = UITextView()
//        contentTextView.delegate = self
        contentTextView.backgroundColor = .clear
        self.contentTextView = contentTextView
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
        }
        
        toolbarItems = [trashItem, spaceItem, cameraItem, spaceItem, composeItem]
        
        //navigation bar
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.setRightBarButton(shareToItem, animated: false)
    }
}

