//
//  CreateEdgeArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

class CreateEdgeArgs {
    var type: Int32
    var name: String
    var stime: Int64
    var bvid: Data?
    var evid: Data?
    var besak: Data?
    var eesak: Data?
    
    init?(type: Int32, name: String, isEncrypt: Bool, bvid: Data? = nil, evid: Data? = nil) {
        self.type = type
        self.name = name
        self.stime = Int64(Date().timeIntervalSince1970)
        self.bvid = bvid
        
        var besak: Data?
        var eesak: Data?
        
        if isEncrypt {
            guard let c = AiTmed.shared.c, let sk = c.sk, let keyPair = AiTmed.shared.e.generateXESAK(sendSecretKey: sk, recvPublicKey: c.pk) else {
                return nil
            }
            
            besak = keyPair.0.toData()
            eesak = keyPair.1.toData()
        }
        
        self.besak = besak
        self.eesak = eesak
    }
}

class UpdateEdgeArgs: CreateEdgeArgs {
    let id: Data
    ///isEncrypt must be same as before
    init(id: Data, type: Int32, name: String, isEncrypt: Bool, bvid: Data? = nil, evid: Data? = nil) {
        self.id = id
        super.init(type: type, name: name, isEncrypt: isEncrypt, bvid: bvid, evid: evid)!
    }
}
