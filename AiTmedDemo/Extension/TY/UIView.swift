//
//  UIView.swift
//  NewStartPart
//
//  Created by tongyi on 7/7/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIView: TYExtension {}
extension TY where T: UIView {
    var originX: CGFloat {
        return _raw.frame.origin.x
    }
    
    var originY: CGFloat {
        return _raw.frame.origin.y
    }
    
    var centerX: CGFloat {
        return _raw.center.x
    }
    
    var centerY: CGFloat {
        return _raw.center.y
    }
    
    var width: CGFloat {
        return _raw.frame.width
    }
    
    var height: CGFloat {
        return _raw.frame.height
    }
    
    var minX: CGFloat {
        return originX
    }
    
    var minY: CGFloat {
        return originY
    }
    
    var maxX: CGFloat {
        return _raw.frame.maxX
    }
    
    var maxY: CGFloat {
        return _raw.frame.maxY
    }
    
    func roundedCorner(with radius: CGFloat? = nil) {
        if let radius = radius {
            _raw.layer.cornerRadius = radius
        } else {
            _raw.layer.cornerRadius = _raw.bounds.height * 0.5
        }
        
        _raw.layer.masksToBounds = true
    }
}
