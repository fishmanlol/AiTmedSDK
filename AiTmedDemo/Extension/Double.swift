//
//  Double.swift
//  BluetoothDemo2
//
//  Created by Yi Tong on 6/10/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Double {
    func round(to: Int) -> Double {
        return (self * 100).rounded() / 100
    }
}
