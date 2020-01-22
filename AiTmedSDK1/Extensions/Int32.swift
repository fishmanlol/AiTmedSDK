//
//  Int32.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/21/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension Int32 {
    mutating func set(_ i: Int) {
        self = self | (1 << i)
    }
    
    mutating func unset(_ i: Int) {
        self = self & ~(1 << i)
    }
    
    func isSet(_ i: Int) -> Bool {
        return (1 << i) & self == 1
    }
    
    func isUnset(_ i: Int) -> Bool {
        return (1 << i) & self == 0
    }
}
