//
//  EType.swift
//  Prynote
//
//  Created by Yi Tong on 11/12/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

public struct AiTmedType {
    //Create Edge
    static let sendOPTCode: Int32 = 1010
    static let login: Int32 = 1030
    static let retrieveCredential: Int32 = 1040
    
    //Retreieve edge
    static let notebook: Int32 = 10001
    static let root: Int32 = 10000
    
    //CreateVertex
    static let user: Int32 = 1
    
    //CreateDoc
    static let embedData: Int32 = 10001
    static let s3Data: Int32 = 10002
}

enum ObjectType: Int32 {
    case vertex = 0
    case doc = 1
    case edge = 2
    
    var code: Int32 { return self.rawValue }
}

enum Gender {
    case pns
    case male
    case female
}
