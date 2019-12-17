//
//  UINavigationController.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/17/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UINavigationController {
    func pushViewControllerFromLeft(_ viewController: UIViewController, animated: Bool) {
        if animated {
            let transition = CATransition()
            transition.duration = 0.35
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            view.layer.add(transition, forKey: nil)
        }
        
        pushViewController(viewController, animated: false)
    }
    
}
