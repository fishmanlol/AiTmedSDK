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
    func transform(args: CreateDocumentArgs) -> Promise<(Doc, Data?)> {
        return Promise<(Doc, Data?)> { resolver in
            if let error = checkStatus() {
                resolver.reject(error)
                return
            }
            
            var doc = Doc()
            
            //firstly, check whether need zip
            var data = args.rawContent
            
            //if text, consider zip.
            if args.mime == .html || args.mime == .json || args.mime == .plain {
                //compare the size of data and zipped data to decide whether zip is needed
                let zipped = data.zip()
                if zipped.count < data.count {
                    data = zipped
                }
            }
            
            //compose name dict
            var dict: [String: Any] = ["title": args.title, "type": args.mime.rawValue]
            
            //if encrypt, fetch besak
            
            DispatchQueue.global().async {
                let sem = DispatchSemaphore(value: 0)
                if args.isEncrypt {
                    AiTmed.xeskPairInEdge(args.folderID).done { (keypair) in
                        if let kp = keypair  {
                            
                        }
                        sem.signal()
                    }.catch { (error) in
                        resolver.reject(error)
                        return
                    }
                    sem.wait()
                }
                
                //if content is text and short enough to store on server
                if data.isEmbedSatisfied {
                    dict["data"] = data.base64EncodedString()//Save data on server
                } else if !args.isBinary{//is data store on S3, we need consider whether store it as binary or base64
                    data = data.base64EncodedData()
                }
                
                guard let name = dict.toJSON() else {
                    resolver.reject(AiTmedError.unkown)
                    return
                }
                
                //caculate type, small end
                var type: Int32 = 0
                if data.isEmbedSatisfied {
                    type = type << 1
                } else {
                    type = type << 0
                }
                
                if data.isZipSatisfied {
                    type = type << 1
                }
                
                doc.type = 
                doc.name = name
                doc.eid = args.folderID//the folder which doc store in
                doc.size = Int32(data.count)//the size of content of doc
                
                if let updateArgs = args as? UpdateDocumentArgs {
//                    doc.id = updateArgs.id
                }
                
                let returnedData = data.isEmbedSatisfied ? nil : data
                resolver.fulfill((doc, returnedData))
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
