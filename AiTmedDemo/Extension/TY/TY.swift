//
//  TY.swift
//  Prynote
//
//  Created by Yi Tong on 10/21/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

public class TY<T> {
    let _raw: T
    
    init(_ raw: T) {
        self._raw = raw
    }
}

public protocol TYExtension {}
public extension TYExtension {
    var ty: TY<Self> {
        get { return TY(self) }
        set {}
    }
    
    static var ty: TY<Self>.Type {
        get { return TY.self}
        set {}
    }
}
