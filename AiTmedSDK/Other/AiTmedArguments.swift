//
//  Arguments.swift
//  AiTmed-framework
//
//  Created by Yi Tong on 11/25/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//Edge
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

public struct RetrieveNotebooksArgs{
    let phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
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
