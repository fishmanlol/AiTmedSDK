//
//  File.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//import Foundation
//import UIKit
//

//Different from Edge and Vertex, Doc is more complicate. For example, the content of Doc may store on server or S3, the content may be zipped or not, the content may be encrypted or not. So we add one layer Document above Doc
//immature document don't have id and did not exchange with backend
struct Document {
    public let id: Data
    public let folderID: Data
    public let title: String
    public var content: Data
    public var isBroken = false
    private var downloadURL: String?
    private var uploadURL: String?
    
    //Reference - https://demo.codimd.org/ZV_6kJ4TQu2ExkraJgWTdw, 1 is true, 0 is false
    public let isOnServer: Bool
    public let isZipped: Bool
    public let isBinary: Bool //the format of content is binary
    public let isEncrypted: Bool //
    public let isExtraKeyNeeded: Bool // determine the data needs extra key to decrypt
    
    public let isInvitable: Bool
    public let isEditable: Bool
    public let isViewable: Bool
    
    public let mime: MediaType
    
    //the type of document which include all information
    func type() -> Int32 {
        
    }
    
    //return internal doc type
    func doc() -> Doc {
        return Doc()
    }
    
    init(id: Data, folderID: Data, title: String, content: Data, isBroken: Bool, isOnServer: Bool, isZipped: Bool, isBinary: Bool, isEncrypted: Bool, isExtraKeyNeeded: Bool, isInvitable: Bool, isEditable: Bool, isViewable: Bool) {
        self.id = id
        self.folderID = folderID
        self.title = title
        self.content = content
        self.isBroken = isBroken
        self.isOnServer = isOnServer
        self.isZipped = isZipped
        self.isBinary = isBinary
        self.isEncrypted = isEncrypted
        self.isExtraKeyNeeded = isExtraKeyNeeded
        self.isInvitable = isInvitable
        self.isEditable = isEditable
        self.isViewable = isViewable
    }
}


//class MatureDocument: ImmatureDocument {
//    public let id: Data
//
//    init(id: Data, forlderID: Data, title: String, content: Data, isBroken: Bool, isOnServer: Bool, isZipped: Bool, isBinary: Bool, isEncrypted: Bool, isExtraKeyNeeded: Bool, isInvitable: Bool, isEditable: Bool, isViewable: Bool) {
//        self.id = id
//        super.init(folderID: folderID, title: title, content: content, isBroken: isBroken, isOnServer: isOnServer, isZipped: isZipped, isBinary: isBinary, isEncrypted: isEncrypted, isExtraKeyNeeded: isExtraKeyNeeded, isInvitable: isInvitable, isEditable: isEditable, isViewable: isViewable)
//    }
//}

public enum MediaType: String {
    case plain = "text/plain"
    case html = "text/html"
    case json = "application/json"
    case other
    
    var kind: MediaTypeKind {
        if rawValue.hasPrefix("text") {
            return .text
        } else if rawValue.hasPrefix("application") {
            return .application
        } else {
            return .other
        }
    }
}

public enum MediaTypeKind: Int32 {
    case other = 0
    case application
    case audio
    case font
    case image
    case message
    case model
    case multipart
    case text
    case video
}
