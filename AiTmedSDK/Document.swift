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


public struct Document {
    public var id: Data
    public var title: String = ""
    public var content: Data?
    public var isEncrypt: Bool = false
    public var type: MimeType = .plain
    public var isBroken = false
    var isOnS3 = false
    var isZipped = false
    var downloadURL: URL?
    var uploadURL: URL?
    
    init(_ doc: Doc) {
        self.id = doc.id
        if let json = doc.name.toJSONDict() {
            if json["isGzip"] as? Bool == true {
                isZipped = true
            }
            
            if json["isOnS3"] as? Bool == true {
                isOnS3 = true
            }
            
            if json["isOnS3"] as? Bool == false, let contentBase64 = json["data"] as? String {
                content = Data(base64Encoded: contentBase64)
            }
        }
        
        if let json = doc.deat.toJSONDict() {
            if let url = json["url"] as? String {
                downloadURL = URL(string: url)
                
                if let sig = json["sig"] as? String {
                    uploadURL = URL(string: url + sig)
                }
            }
        }
    }
}

public enum MimeType: String {
    case html = "text/html"
    case markdown = "text/markdown"
    case plain = "text/plain"
    case png
    case jpeg
    case json
    case data
}

//public enum MimeType: String {
//    case html = "text/html"
//    case markdown = "text/markdown"
//    case plain = "text/plain"
//    case png
//    case jpeg
//    case json
//    case data
//}
//
//public class File {
//    public var id: Data?
//    public var title: String?
//    public var content: Data?
//    public var isEncrypt: Bool = false
//    public var type: MimeType = .plain
//
//    static func load(from doc: Doc, completion: @escaping (Result<File, AiTmedError>) -> Void) {
//        let file = File()
//        file.id = doc.id
//        var isZipped = false
//        var isOnS3 = false
//
//        if let json = doc.name.toJSONDict() {
//            if json["isGzip"] as? Bool == true {
//                isZipped = true
//            }
//
//            if json["isOnS3"] as? Bool == true {
//                isOnS3 = true
//            }
//
//            if json["isOnS3"] as? Bool == false, let contentBase64 = json["data"] as? String {
//                file.content = Data(base64Encoded: contentBase64)
//            }
//
//            if isOnS3 {
//
//            }
//        } else{
//            completion(.failure(.unkown))
//        }
//    }
//}
