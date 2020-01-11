//
//  UpdateEdgeArgs.swift
//  AiTmedSDK1
//
//  Created by tongyi on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

struct UpdateEdgeArgs {
    let type: Int32
    let name: String
    let stime: Int64
    let bvid: Data
    
    init(type: Int32, name: String, bvid: Data) {
        self.type = type
        self.name = name
        self.stime = Int64(Date().timeIntervalSince1970)
        self.bvid = bvid
    }
}
