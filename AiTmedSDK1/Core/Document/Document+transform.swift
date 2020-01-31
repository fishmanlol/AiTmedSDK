//
//  AiTmed+createTransform.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import PromiseKit

extension AiTmed {
    ///transform arguments to Doc and processed data(if data not nil means it will be sent to S3)
    ///Doc is used as parament in createDoc function
    ///Data will upload to S3 if isOnServer is false
    func transform(args: CreateDocumentArgs) -> Promise<(Doc, Data)> {
        return Promise<(Doc, Data)> { resolver in
            if let error = checkStatus() {
                resolver.reject(error)
                return
            }
            
            var doc = Doc()
            //firstly, check whether need zip
            var data = args.content
            
            //compose name dict
            var dict: [String: Any] = ["title": args.title, "type": args.mediaType.rawValue]
            
            DispatchQueue.global().async {
                //if zip needed
                if args.isZipped, let zipped = try? data.zip() {
                    data = zipped
                }
                
                //if encrypt, fetch besak
                if args.isEncrypt {
                    let result = AiTmed.beskInEdge(args.folderID)
                    switch result {
                    case .failure(let error):
                        resolver.reject(error)
                        return
                    case .success(let _besak):
                        if let besak = _besak,
                            let sk = self.c.sk,
                            let sak = self.e.generateSAK(xesak: besak, sendPublicKey: self.c.pk, recvSecretKey: sk),
                            let encryptedData = self.e.sKeyEncrypt(secretKey: sak, data: [UInt8](data))  {
                            data = Data(encryptedData)
                            dict["data"] = data.base64EncodedString()
                        } else {
                            resolver.reject(AiTmedError.unkown)
                            return
                        }
                    }
                } else {
                    if args.isOnServer {
                        dict["data"] = data.base64EncodedString()
                    }
                }
                
                guard let name = dict.toJSON() else {
                    resolver.reject(AiTmedError.unkown)
                    return
                }
                
                doc.name = name
                doc.eid = args.folderID//the folder which doc store in
                doc.size = Int32(data.count)//the size of content of doc
                var type = DocumentType(value: 0)
                type.isOnServer = args.isOnServer
                type.isZipped = args.isZipped
                type.isBinary = args.isBinary
                type.isEncrypt = args.isEncrypt
                type.isExtraKeyNeeded = args.isExtraKeyNeeded
                type.isEditable = args.isEditable
                type.applicationDataType = args.applicationDataType
                type.mediaTypeKind = args.mediaType.kind
                doc.type = Int32(type.value)
                resolver.fulfill((doc, data))
            }
        }
    }
}
