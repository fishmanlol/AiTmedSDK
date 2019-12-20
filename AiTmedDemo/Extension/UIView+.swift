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
}
