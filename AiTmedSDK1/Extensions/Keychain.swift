//
//  Keychain.swift
//  AiTmed
//
//  Created by Yi Tong on 11/27/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    subscript(key: String) -> Key? {
        get {
            let data: Data?
            #if swift(>=5.0)
            data = try? getData(key)
            #else
            data = (try? getData(key)).flatMap { $0 }
            #endif
            if let data = data {
                return Key(data)
            } else {
                return nil
            }
        }
        
        set {
            if let value = newValue {
                let _ = try? set(value.toData(), key: key)
            } else {
                let _ = try? remove(key)
            }
        }
    }
}
