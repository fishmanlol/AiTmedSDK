//
//  RootViewController.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    lazy var rootSplit = freshSplitViewController()
    var storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var isHorizontallyRegular: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
    
    lazy var stateCoordinator: StateCoordinator = {
        let coordinator = StateCoordinator()
        coordinator.delegate = self
        return coordinator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installRootSplit()
        configureRootSplit()
        configureObservers()
        
        storage.loadNotebooks()
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(signinRequired), name: .signinRequried, object: nil)
    }
    
    private func configureRootSplit() {
        if isHorizontallyRegular {
            configure(master: [freshNotebookVC()], detail: freshPlaceholderViewController(), in: rootSplit)
        } else {
            configure(master: [freshNotebookVC()], detail: nil, in: rootSplit)
        }
    }
    
    private func primaryNav(_ split: UISplitViewController) -> UINavigationController {
        guard let navigation = split.viewControllers.first as? UINavigationController  else {
            fatalError("Configuration of split view controller error")
        }
        
        return navigation
    }
    
    private func configure(master: [UIViewController], detail: UIViewController?, in split: UISplitViewController) {
        let nav = primaryNav(split)
        nav.viewControllers = master
        split.viewControllers = [nav, detail].compactMap { $0 }
    }
    
    private func installRootSplit() {
        rootSplit.delegate = self
        rootSplit.preferredDisplayMode = .allVisible
        addChild(rootSplit)
        view.addSubview(rootSplit.view)
        rootSplit.didMove(toParent: self)
        
        let nav = primaryNav(rootSplit)
        nav.navigationBar.prefersLargeTitles = true
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.setBackgroundImage(R.image.paper_light(), for: .default)
        nav.navigationBar.isTranslucent = true
        nav.setToolbarHidden(false, animated: false)
        nav.toolbar.isTranslucent = false
        nav.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        nav.toolbar.setBackgroundImage(R.image.paper_light(), forToolbarPosition: .any, barMetrics: .default)
    }
    
    private func editorViewController() -> EditorViewController? {
        if rootSplit.viewControllers.count > 1,
            let nav = rootSplit.viewControllers[1] as? UINavigationController,
            let editor = nav.viewControllers.first as? EditorViewController {
            return editor
        }
        return nil
    }
    
    private func rootSplitNavStack(in state: NavigationState) -> Bool {
        let navigation = primaryNav(rootSplit)
        let count = navigation.viewControllers.count
        if count == 1 {
            return state == .notebookOnly
        }
        
        if count == 3 {
            return state == .all
        }
        
        if count == 2 {
            if navigation.viewControllers[1] is NotesViewController {
                return state == .notebookAndNotes
            }
            
            if navigation.viewControllers[1] is EditorViewController {
                return state == .notebookAndEditor
            }
        }
        
        return false
    }
    
    enum NavigationState: Int {
        case notebookOnly = 1
        case notebookAndNotes
        case notebookAndEditor
        case all
    }
}

extension RootViewController {
    func freshSplitViewController() -> UISplitViewController {
        let split = UISplitViewController()
        let navigation = UINavigationController()
        split.viewControllers = [navigation]
        return split
    }
    
    func freshPlaceholderViewController() -> UIViewController {
        return PlaceholderViewController.initWithPlaceholder()
    }
    
    func freshNotebookVC() -> NotebookViewController {
        let vc = NotebookViewController(storage)
        vc.stateCoordinator = stateCoordinator
        return vc
    }
    
    func freshNotesVC(notesGroup: NotesGroup) -> NotesViewController {
        let vc = NotesViewController(storage: storage, notesGroup: notesGroup)
        vc.stateCoordinator = stateCoordinator
        return vc
    }
    
    func freshEditor(_ note: Note) -> EditorViewController {
        let editor = EditorViewController(note: note, storage: storage)
        editor.navigationItem.leftBarButtonItem = rootSplit.displayModeButtonItem
        editor.navigationItem.leftItemsSupplementBackButton = true
        return editor
    }
    
    func freshNavigation(root: UIViewController) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: root)
        navigation.setToolbarHidden(false, animated: false)
        navigation.toolbar.isTranslucent = false
        navigation.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigation.toolbar.setBackgroundImage(R.image.paper_light(), forToolbarPosition: .any, barMetrics: .default)
        
        navigation.navigationBar.shadowImage = UIImage()
        navigation.navigationBar.setBackgroundImage(R.image.paper_light(), for: .default)
        navigation.navigationBar.isTranslucent = true
        return navigation
    }
}

extension RootViewController: StateCoordinatorDelegate {
    func didSelectedNotesGroup(_ notesGroup: NotesGroup) {
        let navigation = primaryNav(rootSplit)
        navigation.pushViewController(freshNotesVC(notesGroup: notesGroup), animated: true)
    }
    
    func didSelectedNote(_ note: Note?) {
        if let note = note {
            let editor = freshEditor(note)
            let navigation = primaryNav(rootSplit)
            if let notesVC = navigation.topViewController as? NotesViewController {
                editor.delegate = notesVC
            }
            if isHorizontallyRegular {
                rootSplit.viewControllers = [navigation, freshNavigation(root: editor)]
            } else {
                navigation.pushViewController(editor, animated: true)
            }
        } else {
            if isHorizontallyRegular {
                rootSplit.viewControllers = [primaryNav(rootSplit), freshPlaceholderViewController()]
            }
        }
    }
}

extension RootViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if secondaryViewController is PlaceholderViewController {
            return true
        }
        
        let navigation = primaryNav(rootSplit)
        var stack = navigation.viewControllers
        
        if let editor = editorViewController() {
            stack.append(editor)
            navigation.viewControllers = stack
            return true
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let navigation = primaryNav(rootSplit)
        let stack = navigation.viewControllers
        
        if rootSplitNavStack(in: .all) {
            if let editor = stack[2] as? EditorViewController {
                navigation.viewControllers = [stack[0], stack[1]]
                return freshNavigation(root: editor)
            } else {
                return nil
            }
        }
        
        if rootSplitNavStack(in: .notebookAndNotes) || rootSplitNavStack(in: .notebookAndEditor) || rootSplitNavStack(in: .notebookOnly) {
            navigation.viewControllers = stack
            if let editor = editorViewController() {
                return freshNavigation(root: editor)
            } else {
                rootSplit.preferredDisplayMode = .allVisible
                return freshPlaceholderViewController()
            }
        }
        
        return nil
    }
}

//MARK: - Notification handlers
extension RootViewController {
    @objc func signinRequired(no: Notification) {
        dismissWaitingView()
        displayAlert(title: "Fatal error", msg: "Please sign in again", actionTitle: "OK") {
            self.present(StartViewController(), animated: true, completion: nil)
        }
    }
}
