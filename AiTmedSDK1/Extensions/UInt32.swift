//
//  Int32.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/21/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension UInt32 {
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
    
    mutating func unset(from s: Int, through e: Int) {
        guard e >= s else { return }
        (s...e).forEach { unset($0) }
    }
    
    mutating func set(from s: Int, through e: Int, with v: UInt32) {
        unset(from: s, through: e)
        var value = v << s
        value.unset(from: e + 1, through: 31)
        self = self | value
    }
    
    func value(from s: Int, through e: Int) -> UInt32 {
        var tmp = self
        tmp.unset(from: e + 1, through: 31)
        tmp = tmp >> s
        return tmp
    }
}
