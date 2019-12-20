//
//  Functions.swift
//  Prynote1
//
//  Created by tongyi on 12/17/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

func getVisibleViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {
    
    var rootVC = rootViewController
    if rootVC == nil {
        rootVC = UIApplication.shared.keyWindow?.rootViewController
    }
    
    if rootVC?.presentedViewController == nil {
        return rootVC
    }
    
    if let presented = rootVC?.presentedViewController {
        if presented.isKind(of: UINavigationController.self) {
            let navigationController = presented as! UINavigationController
            return navigationController.viewControllers.last!
        }
        
        if presented.isKind(of: UITabBarController.self) {
            let tabBarController = presented as! UITabBarController
            return tabBarController.selectedViewController!
        }
        
        return getVisibleViewController(presented)
    }
    return nil
}

func getRootViewController() -> UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
}
