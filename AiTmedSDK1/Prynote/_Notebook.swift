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
        public var ctime: Date
        public var mtime: Date
        
        init(id: Data, title: String, isEncrypt: Bool, ctime: Int64, mtime: Int64) {
            self.id = id
            self.title = title
            self.isEncrypt = isEncrypt
            self.ctime = Date(timeIntervalSince1970: TimeInterval(ctime))
            self.mtime = Date(timeIntervalSince1970: TimeInterval(mtime))
        }
    }
}
