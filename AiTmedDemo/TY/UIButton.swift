//
//  UIButton.swift
//  Prynote
//
//  Created by Yi Tong on 10/21/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

extension TY where T: UIButton {
    
//    private var timer: Timer? {
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.countDownTimerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
//        }
//        
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.countDownTimerKey) as? Timer
//        }
//    }
//    
//    private var originalTitle: String? {
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.buttonOriginalTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN)
//        }
//        
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.buttonOriginalTitleKey) as? String
//        }
//    }
//    
//    private var originalBackgroundColor: UIColor? {
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.originalBackgroundColorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
//        }
//        
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.originalBackgroundColorKey) as? UIColor
//        }
//    }
//    
//    private var activityIndicator: UIActivityIndicatorView {
//        get {
//            if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.activityIndicatorKey) as? UIActivityIndicatorView {
//                return indicator
//            } else {
//                let indicator = UIActivityIndicatorView(style: .white)
//                objc_setAssociatedObject(self, &AssociatedKeys.activityIndicatorKey, indicator, .OBJC_ASSOCIATION_RETAIN)
//                return indicator
//            }
//        }
//    }
//    
//    func startAnimating() {
//        DispatchQueue.main.async {
//            self.activityIndicator.frame = CGRect(x: _raw.x, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
//            self._raw.addSubview(self.activityIndicator)
//            
//        }
//    }
//    
//    func endAnimating() {
//        
//    }
//    
//    func startCountDown(_ seconds: Int) {
//        DispatchQueue.main.async {
//            if self.originalTitle == nil {
//                self.originalTitle = self._raw.title(for: .normal)
//            }
//            
//            if self.originalBackgroundColor == nil {
//                self.originalBackgroundColor = self._raw.backgroundColor
//            }
//            
//            if self.timer != nil {
//                self.stopCountDown()
//            }
//            
//            var s = seconds
//            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
//                if s <= 0 {
//                    self.stopCountDown()
//                    return
//                }
//                
//                self.countDown(s)
//                s -= 1
//            })
//            
//            self.timer?.fire()
//        }
//
//    }
//    
//    func stopCountDown() {
//        DispatchQueue.main.async {
//            self._raw.isEnabled = true
//            self._raw.setTitle(self.originalTitle, for: .normal)
//            self._raw.backgroundColor = self.originalBackgroundColor
//            self.timer?.invalidate()
//            self.timer = nil
//        }
//    }
//    
//    private func countDown(_ second: Int) {
//        _raw.isEnabled = false
//        _raw.setTitle("\(second) seconds", for: .normal)
//        _raw.backgroundColor = UIColor.ty.lightGray
//    }
}
