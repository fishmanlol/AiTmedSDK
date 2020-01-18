//
//  Vertex+arguments.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

//MARK: - Create
class CreateVertexArgs {
    let type: Int32
    ///Now, tage is verification code
    let tage: Int32
    ///Now, uid is phone number
    let uid: String
    let pk: Data
    let esk: Data
    let sk: Data
    
    init(type: Int32, tage: Int32, uid: String, pk: Data, esk: Data, sk: Data) {
        self.type = type
        self.tage = tage
        self.uid = uid
        self.pk = pk
        self.esk = esk
        self.sk = sk
    }
}

//MARK: - Update
class UpdateVertexArgs: CreateVertexArgs {
    let id: Data//the id of this vertex
    
    init(id: Data, type: Int32, tage: Int32, uid: String, pk: Data, esk: Data, sk: Data) {
        self.id = id
        super.init(type: type, tage: tage, uid: uid, pk: pk, esk: esk, sk: sk)
    }
}
