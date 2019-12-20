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
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
