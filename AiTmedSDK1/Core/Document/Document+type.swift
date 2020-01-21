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
import PromiseKit

//Different from Edge and Vertex, Doc is more complicate. For example, the content of Doc may store on server or S3, the content may be zipped or not, the content may be encrypted or not. So we add one layer Document above Doc
struct Document {
    public let id: Data
    public let title: String
    public let content: Data
    public var isBroken = false
    private var downloadURL: String?
    private var uploadURL: String?
    
    //Reference - https://demo.codimd.org/ZV_6kJ4TQu2ExkraJgWTdw, 1 is true
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
    
    ///The conent may be stored on S3 or on our server, we need hidden this implementation details
    ///Use the returned Doc to initialize
    static func initDocumentWith(_ doc: Doc) -> Promise<Document> {
        fatalError()
    }
    
//    init(_ doc: Doc) {
//        self.id = doc.id
//        if let json = doc.name.toJSONDict() {
//            if json["isOnS3"] as? Bool == true {
//                isOnS3 = true
//            }
//
//            if json["isOnS3"] as? Bool == false, let contentBase64 = json["data"] as? String {
//                content = Data(base64Encoded: contentBase64)
//            }
//
//            if json["isGzip"] as? Bool == true {
//                isZipped = true
//            }
//
//            if let title = json["title"] as? String {
//                self.title = title
//            }
//
//            if let type = json["type"] as? String, let mime = MimeType(rawValue: type) {
//                self.mime = mime
//            }
//
//            if !isOnS3 && isZipped {
//                content = content?.unzip()
//            }
//        }
//
//        if let json = doc.deat.toJSONDict() {
//            if let url = json["url"] as? String {
//                downloadURL = url
//
//                if let sig = json["sig"] as? String {
//                    uploadURL = url + "?" + sig
//                }
//            }
//        }
//    }
}

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

public enum MediaTypeKind: String {
    case other
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
