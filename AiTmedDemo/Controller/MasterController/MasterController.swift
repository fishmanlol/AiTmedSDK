//
//  Master.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

class MasterController: UIViewController {
    lazy var rootSplit = freshSplitViewController()
    
    var isHorizontallyRegular: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }
    
    lazy var stateCoordinator: StateCoordinator = {
        let coordinator = StateCoordinator()
        coordinator.delegate = self
        return coordinator
    }()
    
    override func   {
        super.viewDidLoad()
        
        installRootSplit()
        configureRootSplit()
    }
    
    func freshSplitViewController() -> UISplitViewController {
        let split = UISplitViewController()
        let navigation = UINavigationController(rootViewController: NotebookViewController(stateCoordinator))
        split.viewControllers = [navigation]
        return split
    }
    
    func freshPlaceholderViewController() -> UIViewController {
        return PlaceholderViewController.initWithPlaceholder()
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
    
    private func configureRootSplit() {
        if isHorizontallyRegular {
            rootSplit.viewControllers = [masterOfSplit(rootSplit), freshPlaceholderViewController()]
        } else {
            rootSplit.viewControllers = [masterOfSplit(rootSplit)]
        }
    }
    
    private func masterOfSplit(_ split: UISplitViewController) -> UIViewController {
        return split.viewControllers[0]
    }
    
    private func notebookVC() -> NotebookViewController {
        return primaryNav(rootSplit).viewControllers[0] as! NotebookViewController
    }
    
    private func primaryNav(_ split: UISplitViewController) -> UINavigationController {
        guard let navigation = split.viewControllers.first as? UINavigationController  else {
            fatalError("Configuration of split view controller error")
        }
        
        return navigation
    }
}

extension MasterController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if secondaryViewController is PlaceholderViewController {
            return true
        }
        
        let navigation = primaryNav(rootSplit)
        var stack = navigation.viewControllers
        
//        if let editor = editorViewController() {
//            stack.append(editor)
//            navigation.viewControllers = stack
//            return true
//        }
        
        return false
    }
    
//    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
//        let navigation = primaryNav(rootSplit)
//        let stack = navigation.viewControllers
//
//        if rootSplitNavStack(in: .all) {
//            if let editor = stack[2] as? EditorViewController {
//                navigation.viewControllers = [stack[0], stack[1]]
//                return freshNavigation(root: editor)
//            } else {
//                return nil
//            }
//        }
//
//        if rootSplitNavStack(in: .notebookAndNotes) || rootSplitNavStack(in: .notebookAndEditor) || rootSplitNavStack(in: .notebookOnly) {
//            navigation.viewControllers = stack
//            if let editor = editorViewController() {
//                return freshNavigation(root: editor)
//            } else {
//                rootSplit.preferredDisplayMode = .allVisible
//                return freshPlaceholderViewController()
//            }
//        }
//
//        return nil
//    }
}
