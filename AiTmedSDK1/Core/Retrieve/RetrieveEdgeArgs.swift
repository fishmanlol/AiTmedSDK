//
//  RetrieveEdgeArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/10/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

public class RetrieveEdgesArgs {
    let ids: [Data]
    let maxCount: Int32?
    let type: Int32
    
    public init(ids: [Data] = [], type: Int32 = 0, maxCount: Int32? = nil) {
        self.ids = ids
        self.maxCount = maxCount
        self.type = type
    }
}
