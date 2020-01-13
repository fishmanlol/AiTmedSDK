//
//  UIViewController+.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/6/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIViewController {
    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
    
    func displayAutoDismissAlert(msg: String, wait: TimeInterval = 1) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayWaitingView(msg: String) {
        let waitingView = WaitingView(msg: msg)
        waitingView.backgroundColor = UIColor(white: 1, alpha: 0.8)
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(waitingView)
        waitingView.snp.makeConstraints { (make) in
            make.edges.equalTo(keyWindow)
        }
    }
    
    func dismissWaitingView() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            for subview in keyWindow.subviews where subview is WaitingView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func displayInputAlert(title: String?, msg: String?, action: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter here"
                textField.textAlignment = .center
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                if let text = alert.textFields?[0].text {
                    action(text)
                }
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayAlert(title: String?, msg: String?, hasCancel: Bool = false, actionTitle: String? = nil, style: UIAlertAction.Style = .default, action: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: actionTitle ?? "OK", style: style) { (_) in
                action?()
            }
            alert.addAction(ok)
            if hasCancel {
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancel)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
