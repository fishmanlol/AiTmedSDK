//
//  File.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import PromiseKit
struct Document {
    let id: Data
    let folderID: Data
    let title: String
    let mediaType: MediaType
    let ctime: Date
    let mtime: Date
    var content: Data
    var isBroken = false
    //Reference - https://demo.codimd.org/ZV_6kJ4TQu2ExkraJgWTdw, 1 is true, 0 is false
    let type: DocumentType
    
    init(id: Data, folderID: Data, title: String, content: Data, isBroken: Bool, mediaType: MediaType, type: DocumentType, mtime: Int64, ctime: Int64) {
        self.id = id
        self.folderID = folderID
        self.title = title
        self.content = content
        self.isBroken = isBroken
        self.type = type
        self.mediaType = mediaType
        self.mtime = Date(timeIntervalSince1970: TimeInterval(mtime))
        self.ctime = Date(timeIntervalSince1970: TimeInterval(ctime))
    }
    
    static func broken(id: Data, folderID: Data) -> Document {
        return Document(id: id, folderID: folderID, title: "", content: Data(), isBroken: true, mediaType: .other, type: 0, mtime: 0, ctime: 0)
    }
    
    //init document with returned Doc from server
    static func initWithDoc(_ doc: Doc) -> Guarantee<Document> {
        
        return DispatchQueue.global().async(.promise) { () -> Document in
            let id = doc.id
            let folderID = doc.eid
            let ctime = doc.ctime
            let mtime = doc.mtime
            let type = DocumentType(value: UInt32(doc.type))
            let brokenDocument = Document.broken(id: id, folderID: folderID)
            
            guard let nameDict = doc.name.toJSONDict() else {
                print(#function, #line)
                return brokenDocument
            }
            
            var title = ""
            if let t = nameDict["title"] as? String {
                title = t
            }
            
            var mediaType: MediaType = .other
            if let mtRawValue = nameDict["type"] as? String,
                let mt = MediaType(rawValue: mtRawValue) {
                mediaType = mt
            } else {
                print(#function, #line)
                return brokenDocument
            }
            
            var content = Data()
            if type.isOnServer {
                if let base64Content = nameDict["data"] as? String,
                    let _content = Data(base64Encoded: base64Content) {
                    content = _content
                }
            } else {
                guard let deatDict = doc.deat.toJSONDict(),
                        let downloadURL = deatDict["url"] as? String else {
                            print(#function, #line)
                    return brokenDocument
                }
                
                do {
                    let __content = try AiTmed.download(from: downloadURL).wait()
                    if !type.isBinary {
                        if let _content = Data(base64Encoded: __content) {
                            content = _content
                        } else {
                            print(#function, #line)
                            return brokenDocument
                        }
                    }
                }  catch {
                    print(#function, #line)
                    return brokenDocument
                }
            }
            
            //now, content is binary data either from S3 or server
            
            //decrypt if needed
            if type.isEncrypt {
                do {
                    let besak = try AiTmed.besakInEdge(folderID).wait()
                    let pk = AiTmed.shared.c.pk
                    guard let sk = AiTmed.shared.c.sk,
                        let sak = AiTmed.shared.e.generateSAK(xesak: besak, sendPublicKey: pk, recvSecretKey: sk),
                        let decrypted = AiTmed.shared.e.sKeyDecrypt(secretKey: sak, data: [UInt8](content)) else {
                            print(#function, #line)
                            return brokenDocument
                    }
                    
                    print("retrieve encrypt:", [UInt8](content))
                    content = Data(decrypted)
                    print("retrieve deencrypt:", [UInt8](content))
                } catch {
                    print(#function, #line)
                    return brokenDocument
                }
            }
            
            //unzip if needed
            if type.isZipped {
                if let unzipped = try? content.unzip() {
                    print("retrieve zip: ", [UInt8](content))
                    content = unzipped
                    print("retrieve unzip: ", [UInt8](content))
                } else {
                    print(#function, #line)
                    return brokenDocument
                }
            }
            
            return Document(id: id, folderID: folderID, title: title, content: content, isBroken: false, mediaType: mediaType, type: type, mtime: mtime, ctime: ctime)
        }
    }
}


