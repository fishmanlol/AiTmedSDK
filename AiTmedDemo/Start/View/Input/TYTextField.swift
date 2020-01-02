//
//  TYTextField.swift
//  NewStartPart
//
//  Created by tongyi on 7/7/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class TYTextField: UITextField {
    
    private var bottomLineLayer: CALayer!
    
    //Bottom line
    var bottomLineHeight: CGFloat = 1.2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var bottomLineColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let startPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.lineWidth = bottomLineHeight
        bottomLineColor.setStroke()
        path.stroke()
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        print(super.editingRect(forBounds: bounds))
        return super.editingRect(forBounds: bounds)
    }
}
