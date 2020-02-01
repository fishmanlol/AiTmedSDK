//
//  Dictionary+.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension Dictionary where Key == AiTmedNameKey {
    func toJSON() -> String? {
        var newDict: [String: Value] = [:]
        
        for (key, value) in self {
            newDict[key.rawValue] = value
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: newDict, options: []) else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
}

extension Dictionary where Key == String {
    func toJSON() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
}
