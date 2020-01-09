//
//  CreateEdgeArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

struct CreateEdgeArgs {
    let type: Int32
    let name: String
    let stime: Int64
    var bvid: Data?
    var besak: Data?
    var eesak: Data?
    
    init(type: Int32, name: String, bvid: Data? = nil, besak: Data? = nil, eesak: Data? = nil) {
        self.type = type
        self.name = name
        self.stime = Int64(Date().timeIntervalSince1970)
        self.bvid = bvid
        self.besak = besak
        self.eesak = eesak
    }
}
