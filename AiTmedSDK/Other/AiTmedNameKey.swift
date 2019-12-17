//
//  AiTmedKey.swift
//  Prynote
//
//  Created by Yi Tong on 11/11/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

public enum AiTmedNameKey: String {
    case phoneNumber = "phone_number"
    case userId = "user_id"
    case OPTCode = "verification_code"
    case pk = "pk"
    case esk = "esk"
}

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

extension String {
    func toJSONDict() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}
