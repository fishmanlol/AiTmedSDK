//
//  UserDefaults+.swift
//  AiTmed
//
//  Created by Yi Tong on 11/26/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension UserDefaults {
    func setKey(_ value: Key?, forKey key: String) {
        setValue(value?.toData(), forKey: key)
    }
    
    func getKey(forKey key: String) -> Key? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return Key(data)
    }
}
