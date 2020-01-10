//
//  UIViewController+froze.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import UIKit

private var ghostViewKey: Void = ()

extension UIViewController {
    private var ghostView: UIView? {
        get {
            return objc_getAssociatedObject(self, &ghostViewKey) as? UIView
        }
        
        set {
            objc_setAssociatedObject(self, &ghostViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func froze() {
        DispatchQueue.main.async {
            if self.ghostView == nil {
                let v = UIView()
                v.backgroundColor = .clear
                self.ghostView = v
            }
            
            self.view.addSubview(self.ghostView!)
            self.ghostView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func defroze() {
        DispatchQueue.main.async {
            self.ghostView?.removeFromSuperview()
        }
    }
}
