//
//  Arguments.swift
//  AiTmed-framework
//
//  Created by Yi Tong on 11/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//Edge
import Foundation

public struct SendOPTCodeArgs {
    let phoneNumber: String
    
    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}

public struct LoginArgs {
    let phoneNumber: String
    let password: String
    
    public init(phoneNumber: String, password: String) {
        self.phoneNumber = phoneNumber
        self.password = password
    }
}

public struct RetrieveCredentialArgs {
    let phoneNumber: String
    let code: String
    
    public init(phoneNumber: String, code: String) {
        self.phoneNumber = phoneNumber
        self.code = code
    }
}

public class RetrieveNotebooksArgs: RetrieveEdgeArgs {
    public override init(ids: [Data] = [], maxCount: Int32? = nil) {
        super.init(ids: ids, maxCount: maxCount)
        
        type = AiTmedType.notebook
    }
}

public struct CreateOrUpdateNotebookArgs {
    let title: String
    let isEncrypt: Bool
    let type: Int
    
    public init(title: String, isEncrypt: Bool, type: Int = 7) {
        self.title = title
        self.isEncrypt = isEncrypt
        self.type = type
    }
}

public struct RemoveArgs {
    let id: [Data]
    init(id: [Data]) {
        self.id = id
    }
}

///Application can not use this directly
public class RetrieveEdgeArgs {
    let ids: [Data]
    let maxCount: Int32?
    var type: Int32!
    
    public init(ids: [Data] = [], maxCount: Int32? = nil) {
        self.ids = ids
        self.maxCount = maxCount
    }
}

//Vertex
public struct CreateUserArgs {
    let phoneNumber: String
    let password: String
    let code: Int32
    
    public init(phoneNumber: String, password: String, code: Int32) {
        self.phoneNumber = phoneNumber
        self.password = password
        self.code = code
    }
}

//Doc

struct Validator {
    static func phoneNumber(_ phoneNumber: String) -> Bool {
        let reg = #"^\+\d{1,4} \d{1,18}$"#
        return phoneNumber.range(of: reg, options: .regularExpression) != nil
    }
    
    static func password(_ password: String) -> Bool {
        return true
    }
}

protocol PrettyPrintable: CustomStringConvertible {}

extension PrettyPrintable  {
    public var description: String {
        let mirror = Mirror(reflecting: self)
        print("\(type(of: self))-----------------------------------------------------")
        for (k,v) in mirror.children {
            if case Optional<Any>.some(let value) = v, let k = k {
                print(k + ": " + String(describing: value))
            }
        }
        print("-----------------------------------------------------")
        return ""
    }
}
