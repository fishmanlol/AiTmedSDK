//
//  Notification.swift
//  Prynote
//
//  Created by Yi Tong on 10/22/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

extension Notification: TYExtension {}
extension TY where T == Notification {
    func keyboardAnimationDuration() -> Double? {
        return _raw.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
    
    func keyboardAnimationCurve() -> UInt? {
        return _raw.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
    }
    
    func keyboardEndFrame() -> CGRect? {
        return (_raw.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
}
