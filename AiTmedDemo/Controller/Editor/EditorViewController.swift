//
//  EditorViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/14/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class EditorViewController: UIViewController {
    weak var backgroudImageView: UIImageView!
    weak var titleTextField: UITextField!
    weak var notebookSelectionView: NotebookSelectionView!
    weak var contentTextView: IQTextView!
    weak var scrollView: UIScrollView!
    weak var partBackgroundView: UIImageView!
    
    lazy var doneItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneItemTapped))
    lazy var shareToItem = UIBarButtonItem(image: R.image.share_to(), style: .done, target: self, action: #selector(didShareToItemTapped))
    lazy var trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTrashItemTapped))
    lazy var cameraItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didCameraItemTapped))
    lazy var composeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didComposeItemTapped))
    lazy var spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    lazy var indicatorItem: UIBarButtonItem = {
        let indictor = UIActivityIndicatorView(style: .gray)
        indictor.hidesWhenStopped = true
        indictor.startAnimating()
        return UIBarButtonItem(customView: indictor)
    }()
    
    let notebook: Notebook
    var mode: Mode
    let stateCoordinator: StateCoordinator
    let keyboard = Keyboard()
    
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
        let sv = UIScrollView(frame: UIScreen.main.bounds)
        self.scrollView = sv
        self.view = sv
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        partBackgroundView.snp.updateConstraints { $0.height.equalTo(topBarHeight + 44)}
    }
    
    //MARK: - Action
    @objc func dismissItemTapped() {
        view.endEditing(true)
    }
    
    @objc func didTapGesureRecognized(tap: UITapGestureRecognizer) {
        let location = tap.location(in: nil)
        if location.y > titleTextField.frame.maxY {
            contentTextView.becomeFirstResponder()
        }
    }
    
    @objc func didTrashItemTapped() {
//        displayWaitingView(msg: "Removing...")
//        note.notebook.remove(note)
    }
    
    @objc func didCameraItemTapped() {
        displayAutoDismissAlert(msg: "Not implemented yet")
    }
    
    @objc func didComposeItemTapped() {
//        notebook.add(note)
    }
    
    @objc func didShareToItemTapped() {
        displayAutoDismissAlert(msg: "Not implemented yet")
    }
    
    @objc func didDoneItemTapped() {
        view.endEditing(true)
        isLoading = true
        let title = titleTextField.text ?? ""
        let content = contentTextView.text.data(using: .utf8) ?? Data()
        switch mode {
        case .create:
            notebook.addNote(title: title, content: content) { [weak self] (result) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .failure(let error):
                        self?.displayAutoDismissAlert(msg: error.message)
                    case .success(let note):
                        self?.mode = .update(note)
                        print("create success!")
                    }
                }
            }
        case .update(let note):
            note.update(title: title, content: content) { [weak self] (result) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .failure(let error):
                        self?.displayAutoDismissAlert(msg: error.message)
                    case .success(_):
                        print("update success!")
                    }
                }
            }
        }
    }
    
    private func didChangeLoadingState() {
        if isLoading {
            navigationItem.setRightBarButtonItems([indicatorItem, shareToItem], animated: false)
        } else if IQKeyboardManager.shared.keyboardShowing {
            navigationItem.setRightBarButtonItems([doneItem, shareToItem], animated: false)
        } else {
            navigationItem.setRightBarButtonItems([shareToItem], animated: false)
        }
    }
    
    private func setUp() {
        //navigation bar
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.setRightBarButton(shareToItem, animated: false)
        
        scrollView.backgroundColor = UIColor(patternImage: R.image.paper_light()!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapGesureRecognized))
        scrollView.addGestureRecognizer(tap)
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.width.equalToSuperview()
        }

        let titleTextField = UITextField()
        titleTextField.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        titleTextField.placeholder = "Title..."
        self.titleTextField = titleTextField
        contentView.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.top.equalToSuperview().inset(54)
        }
        
        let contentTextView = IQTextView()
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.toolbarDoneBarButtonItemImage = R.image.arrow_down()
        contentTextView.placeholder = "Start writing here..."
        contentTextView.placeholderTextColor = UIColor.lightGray
        contentTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        contentTextView.isScrollEnabled = false
        contentTextView.returnKeyType = .next
        contentTextView.enablesReturnKeyAutomatically = true
        contentTextView.backgroundColor = .clear
        self.contentTextView = contentTextView
        contentView.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview().inset(16)
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
        }
        
        let partBackgroundView = UIImageView(image: R.image.paper_light())
        self.partBackgroundView = partBackgroundView
        view.addSubview(partBackgroundView)
        partBackgroundView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(0)
        }
        
        let notebookSelectionView = NotebookSelectionView.initWithNib()
        notebookSelectionView.setNotebooktitle(notebook.title)
        self.notebookSelectionView = notebookSelectionView
        view.addSubview(notebookSelectionView)
        notebookSelectionView.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.safeAreaLayoutGuide).offset(8)
            make.right.equalTo(scrollView.safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(36)
            make.top.equalTo(scrollView.safeAreaLayoutGuide).offset(8)
        }
        
        toolbarItems = [trashItem, spaceItem, cameraItem, spaceItem, composeItem]
        
        keyboard.observeKeyboardWillShow { (_) in
            self.navigationItem.setRightBarButtonItems([self.doneItem, self.shareToItem], animated: false)
        }
        
        keyboard.observeKeyboardWillHide { (_) in
            self.navigationItem.setRightBarButtonItems([self.shareToItem], animated: false)
        }
        
        if case let .update(note) = mode {
            titleTextField.text = note.title
            contentTextView.text = note.displayContent
        }
    }
}
