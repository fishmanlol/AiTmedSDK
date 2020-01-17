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

//public class RetrieveNotebooksArgs: RetrieveEdgeArgs {
//    public override init(ids: [Data] = [], maxCount: Int32? = nil) {
//        super.init(ids: ids, maxCount: maxCount)
//        
//        type = AiTmedType.notebook
//    }
//}

public struct CreateNotebookArgs {
    let title: String
    let isEncrypt: Bool
    let type: Int
    
    public init(title: String, isEncrypt: Bool, type: Int = 7) {
        self.title = title
        self.isEncrypt = isEncrypt
        self.type = type
    }
}

public struct UpdateNotebookArgs {
    var id: Data
    var title: String?
    var isEncrypt: Bool?
    var type: Int?
    
    public init(id: Data, title: String?, isEncrypt: Bool?, type: Int?) {
        self.id = id
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

public class RetrieveDocArgs {
    let folderID: Data
    
    public init(folderID: Data) {
        self.folderID = folderID
    }
}



//public class CreateFileArgs {
//    var title: String?
//    var content: Data?
//    var isEncrypt: Bool
//    var folderID: Data
//    var mime: MimeType = .data
//    internal var type: Int32!
//
//    public init(title: String?, content: Data?, isEncrypt: Bool, folderID: Data) {
//        self.title = title
//        self.content = content
//        self.isEncrypt = isEncrypt
//        self.folderID = folderID
//    }
//}


//public class CreateNoteArgs: CreateFileArgs {
//    public override init(title: String?, content: Data?, isEncrypt: Bool, folderID: Data) {
//        super.init(title: title, content: content, isEncrypt: isEncrypt, folderID: folderID)
//        mime = .plain
//
//        if let content = content, let zipped = content.zip(), !zipped.isEmbedded {
//            type = AiTmedType.s3Data
//            if isEncrypt {//encrypt
//
//            }
//        } else {
//            type = AiTmedType.embedData
//        }
//    }
//}

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
