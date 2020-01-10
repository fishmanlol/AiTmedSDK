//
//  _Note.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    public struct _Note {
        public var id: Data
        public var title: String
        public var content: Data
        public var ctime: Date = Date()
        public var mtime: Date = Date()
        public var isBroken = false
    }
}
