//
//  Error+.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/17/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension Error {
    func toAiTmedError() -> AiTmedError {
        return (self as? AiTmedError) ?? AiTmedError.unkown
    }
}
