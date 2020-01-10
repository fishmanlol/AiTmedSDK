//
//  _Notebook.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

public extension AiTmed {
    struct _Notebook {
        public var id: Data
        public var title: String
        public var isEncrypt: Bool
        public var ctime: Date = Date()
        public var mtime: Date = Date()
    }
}
