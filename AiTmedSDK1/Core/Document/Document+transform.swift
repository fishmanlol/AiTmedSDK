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
    func transform(args: CreateDocumentArgs) -> Promise<(Doc, Data, Bool, Bool)> {
        return Promise<(Doc, Data, Bool, Bool)> { resolver in
            if let error = checkStatus() {
                resolver.reject(error)
                return
            }
            
            var doc = Doc()
            var isOnServer = false
            var isZipped = false
            //firstly, check whether need zip
            var data = args.rawContent
            
            //if text, consider zip.
            if args.mime == .html || args.mime == .json || args.mime == .plain {
                //compare the size of data and zipped data to decide whether zip is needed
                let zipped = data.zip()
                if zipped.count < data.count {
                    data = zipped
                    isZipped = true
                }
            }
            
            //compose name dict
            var dict: [String: Any] = ["title": args.title, "type": args.mime.rawValue]
            
            //if encrypt, fetch besak
            
            DispatchQueue.global().async {
                let sem = DispatchSemaphore(value: 0)
                if args.isEncrypt {
                    var success = true
                    AiTmed.xeskPairInEdge(args.folderID).done { (keypair) in
                        if let kp = keypair,
                            let sk = self.c.sk,
                            let sak = self.e.generateSAK(xesak: kp.0, sendPublicKey: self.c.pk, recvSecretKey: sk),
                            let encryptedData = self.e.sKeyEncrypt(secretKey: sak, data: [UInt8](data))  {
                            data = Data(encryptedData)
                        } else {
                            success = false
                        }
                        
                        sem.signal()
                    }.catch { (error) in
                        success = false
                        sem.signal()
                    }
                    sem.wait()
                    
                    if !success {
                        resolver.reject(AiTmedError.unkown)
                    }
                }
                
                //if content is text and short enough to store on server
                if data.isEmbedSatisfied {
                    dict["data"] = data.base64EncodedString()//Save data on server
                    isOnServer = true
                } else if !args.isBinary{//is data store on S3, we need consider whether store it as binary or base64
                    data = data.base64EncodedData()
                }
                
                guard let name = dict.toJSON() else {
                    resolver.reject(AiTmedError.unkown)
                    return
                }
                
                //caculate type,  31|---------------|0
                var type: Int32 = 0
                if data.isEmbedSatisfied {//on server
                    type.set(0)
                } else {
                    type.unset(0)
                }
                
                if data.isZipSatisfied {//is zipped
                    type.set(1)
                } else {
                    type.unset(1)
                }
                
                if args.isBinary { //content format is binary
                    type.set(2)
                } else {
                    type.unset(2)
                }
                
                if args.isEncrypt {//content is encrypt
                    type.set(3)
                } else {
                    type.unset(3)
                }
                
                if args.isExtraKeyNeeded {
                    type.set(4)
                } else {
                    type.unset(4)
                }
                
                if args.isInvitable {
                    type.set(24)
                } else {
                    type.unset(24)
                }
                
                if args.isEditable {
                    type.set(25)
                } else {
                    type.unset(25)
                }
                
                if args.isViewable {
                    type.set(26)
                } else {
                    type.unset(26)
                }
                
                //Save mime type kind(5 bits) to most significant bits on type(32 bits)
                //first, unset 27-31 bits. left shift then right shift
                type = (type << 5) >> 5
                //then, shift mime type to most significant
                let mimeNumber = args.mime.kind.rawValue << 27
                //last, OR operation
                type = type | mimeNumber
                
                doc.type = type
                doc.name = name
                doc.eid = args.folderID//the folder which doc store in
                doc.size = Int32(data.count)//the size of content of doc
                
                if let updateArgs = args as? UpdateDocumentArgs {
                    doc.id = updateArgs.id
                }
                
                resolver.fulfill((doc, data, isOnServer, isZipped))
            }
        }
    }
    
//    func transform(args: CreateDocumentArgs, completion: @escaping (Swift.Result<Doc, AiTmedError>) -> Void) {
//        if let error = checkStatus() {
//            completion(.failure(error))
//            return
//        }
//
//        var content = args.content
//        if args.isZipSatisfied {
//            content = args.content.zip()
//        }
//
//        var dict: [String: Any] = ["title": args.title, "isOnS3": args.isOnS3, "isGzip": args.content.isZipSatisfied, "type": args.mime.rawValue]
//
//        var doc = Doc()
//        doc.eid = args.folderID
//        doc.type = args.type
//        //unit is byte, original content size
//        doc.size = Int32(args.content.count)
//
//        if let arguments = args as? UpdateDocumentArgs {
//            doc.id = arguments.id
//        }
//
//        if args.isEncrypt {
////            AiTmed.xeskPairInEdge(args.folderID) { (result) in
////                switch result {
////                case .failure(let error):
////                    completion(.failure(error))
////                case .success(let keypair):
////                    if let _ = keypair {
////                        if !args.isOnS3 {
////                            dict["data"] = content.base64EncodedString()
////                        }
////
////                        guard let name = dict.toJSON() else {
////                            completion(.failure(.unkown))
////                            return
////                        }
////
////                        doc.name = name
////
////                        if let updateArgs = args as? UpdateDocumentArgs {
////                            doc.id = updateArgs.id
////                        }
////
////                        completion(.success(doc))
////                    } else {
////                        completion(.failure(.unkown))
////                    }
////                }
////            }
//        } else {
//            if !args.isOnS3 {
//                dict["data"] = content.base64EncodedString()
//            }
//
//            guard let name = dict.toJSON() else {
//                completion(.failure(.unkown))
//                return
//            }
//
//            doc.name = name
//
//            if let updateArgs = args as? UpdateDocumentArgs {
//                doc.id = updateArgs.id
//            }
//
//            completion(.success(doc))
//        }
//    }
}
