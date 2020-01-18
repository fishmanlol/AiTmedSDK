//
//  Credential.swift
//  AiTmed
//
//  Created by Yi Tong on 11/26/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import KeychainAccess

struct Credential {
    private let defaults = UserDefaults.standard
    private let keyChain = Keychain(service: "com.aitmed")
    
    let phoneNumber: String
    let pk: Key
    let esk: Key
    let userId: Data
    var jwt: String = "" {
        didSet {
            defaults.setValue(jwt, forKey: "jwt" + phoneNumber)
        }
    }
    
    var sk: Key? {
        didSet {
            keyChain["sk" + phoneNumber] = sk
        }
    }
    
    var status: Status {
        get {
            return sk == nil ? .locked : .login
        }
    }
    
    init?(json: String, for phoneNumber: String) {
        if let dict = json.toJSONDict(),
            let pkStr = dict[AiTmedDeatKey.pk.rawValue] as? String,
            let pk = Key(pkStr),
            let eskStr = dict[AiTmedDeatKey.esk.rawValue] as? String,
            let esk = Key(eskStr),
            let userIdStr = dict[AiTmedDeatKey.userId.rawValue] as? String,
            let userIdBytes = AiTmed.shared.e.base642Bin(userIdStr) {
            self.phoneNumber = phoneNumber
            self.pk = pk
            self.esk = esk
            self.userId = Data(userIdBytes)
        } else {
            print("decode deat of retreive credential failed")
            return nil
        }
    }
    
    init(phoneNumber: String, pk: Key, esk: Key, sk: Key? = nil, userId: Data, jwt: String) {
        self.phoneNumber = phoneNumber
        self.pk = pk
        self.esk = esk
        self.sk = sk
        self.userId = userId
        self.jwt = jwt
    }
    
    init?(phoneNumber: String) {
        guard let pk = defaults.getKey(forKey: "pk" + phoneNumber),
                let esk = defaults.getKey(forKey: "esk" + phoneNumber),
                let jwt = defaults.value(forKey: "jwt" + phoneNumber) as? String,
                let userId = defaults.value(forKey: "userId" + phoneNumber) as? Data else {
                    return nil
        }
        
        self.phoneNumber = phoneNumber
        self.pk = pk
        self.esk = esk
        self.jwt = jwt
        self.userId = userId
        
        if let sk: Key = keyChain["sk" + phoneNumber] {
            self.sk = sk
        }
    }
    
    func save() {
        defaults.setKey(pk, forKey: "pk" + phoneNumber)
        defaults.setKey(esk, forKey: "esk" + phoneNumber)
        defaults.setValue(jwt, forKey: "jwt" + phoneNumber)
        defaults.setValue(userId, forKey: "userId" + phoneNumber)
        
        if let sk = sk {
            keyChain["sk" + phoneNumber] = sk
        }
    }
    
    enum Status {
        case login
        case locked
    }
}





