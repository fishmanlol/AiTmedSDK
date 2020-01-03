//
//  PrynoteError.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/2/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

enum PrynoteError: Error {
    case unkown
    
    var detail: String {
        return "unkown"
    }
}
