//
//  String+.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/9/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension String {
    func toJSONDict() -> [String: Any]? {
        print("before:", self)
        let filtered = removeControlCharacters()
        print("after:", filtered)
        if let data = filtered.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return json as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    private func removeControlCharacters() -> String {
        let cc = CharacterSet.controlCharacters
        return String(filter { cc.contains($0.unicodeScalars.first! )})
    }
}
