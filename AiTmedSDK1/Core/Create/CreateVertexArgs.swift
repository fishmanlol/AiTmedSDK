//
//  CreateVertextArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

struct CreateVertexArgs {
    let type: Int32
    ///Now, tage is verification code
    let tage: Int32
    ///Now, uid is phone number
    let uid: String
    let pk: Data
    let esk: Data
}
