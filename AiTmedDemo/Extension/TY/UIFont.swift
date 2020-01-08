//
//  UIFont.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIFont: TYExtension {}
extension TY where T: UIFont {
    static var largeFontSize: CGFloat { return 24 }
    static var middleFontSize: CGFloat { return 17 }
    static var smallFontSize: CGFloat { return 12 }
    
    static func avenirNext(bold: UIFont.Weight, size: CGFloat) -> UIFont {
        switch bold {
        case .heavy:
            return UIFont(name: "AvenirNext-Heavy", size: size) ?? UIFont.systemFont(ofSize: size)
        case .bold:
            return UIFont(name: "AvenirNext-Blod", size: size) ?? UIFont.systemFont(ofSize: size)
        case .medium:
            return UIFont(name: "AvenirNext-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:
            return UIFont(name: "AvenirNext-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "AvenirNext-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func menlo(bold: UIFont.Weight, size: CGFloat) -> UIFont {
        switch bold {
        case .medium:
            return UIFont(name: "Menlo-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:
            return UIFont(name: "Menlo-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "Menlo-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func pingfang(bold: UIFont.Weight = UIFont.Weight.regular, size: CGFloat) -> UIFont {
        
        let name: String
        
        switch bold {
        case .regular:
            name = "PingFangSC-Regular"
        case .medium:
            name = "PingFangSC-Medium"
        default:
            name = "PingFangSC-Regular"
        }
        
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
