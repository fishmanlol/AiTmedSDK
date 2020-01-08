//
//  UIView+.swift
//  SplitViewControllerDemo
//
//  Created by Yi Tong on 12/4/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIView {
    func rotate(_ angle: CGFloat, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(rotationAngle: angle)
            }, completion: completion)
        } else {
            self.transform = CGAffineTransform(rotationAngle: angle)
            completion?(true)
        }
    }
    
    func pinToInside(_ subview: UIView) {
        subview.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addUnderLineIfNeeded(with color: UIColor = UIColor.lightGray, width: CGFloat = 0.5) {
        var hasUnderLine = false
        if let sublayers = layer.sublayers {
            hasUnderLine = sublayers.contains { $0.name == "underline" }
        }
        
        if !hasUnderLine {
            let subLayer = CALayer()
            subLayer.name = "underline"
            subLayer.backgroundColor = color.cgColor
            subLayer.frame = CGRect(x: 0, y: bounds.height - width, width: bounds.width, height: width)
            self.layer.addSublayer(subLayer)
        }
    }
}
