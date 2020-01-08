//
//  UIButton.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/29/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit

private var indicatorKey: Void?
private var originalTextKey: Void?

extension UIButton {
    private var indicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &indicatorKey) as? UIActivityIndicatorView
        }

        set {
            objc_setAssociatedObject(self,
                &indicatorKey, newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var originalText: String? {
        get {
            return objc_getAssociatedObject(self, &originalTextKey) as? String
        }

        set {
            objc_setAssociatedObject(self,
                &originalTextKey, newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func startAnimating() {
        getIndicator().startAnimating()
        originalText = currentTitle
        setTitle("", for: .normal)
        isEnabled = false
    }

    @objc func endAnimating() {
        getIndicator().stopAnimating()
        setTitle(originalText, for: .normal)
        isEnabled = true
    }
    
    private func getIndicator() -> UIActivityIndicatorView {
        if indicator == nil {
            indicator = UIActivityIndicatorView(style: .gray)
            indicator!.hidesWhenStopped = true
            addSubview(indicator!)
            indicator!.snp.makeConstraints { (make) in
                  make.edges.equalToSuperview()
              }
        }
        
        return indicator!
    }
}
