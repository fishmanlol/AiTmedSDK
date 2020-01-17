//
//  AiTmed+createTransform.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    func transform(args: CreateDocumentArgs, completion: @escaping (Swift.Result<Doc, AiTmedError>) -> Void) {
        if let error = checkStatus() {
            completion(.failure(error))
            return
        }
        
        var content = args.content
        if args.isZipSatisfied {
            content = args.content.zip()
        }
        
        var dict: [String: Any] = ["title": args.title, "isOnS3": args.isOnS3, "isGzip": args.content.isZipSatisfied, "type": args.mime.rawValue]
        
        var doc = Doc()
        doc.eid = args.folderID
        doc.type = args.type
        //unit is byte, original content size
        doc.size = Int32(args.content.count)
        
        if let arguments = args as? UpdateDocumentArgs {
            doc.id = arguments.id
        }
        
        if args.isEncrypt {
            AiTmed.xeskPairInEdge(args.folderID) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let keypair):
                    if let _ = keypair {
                        if !args.isOnS3 {
                            dict["data"] = content.base64EncodedString()
                        }
                        
                        guard let name = dict.toJSON() else {
                            completion(.failure(.unkown))
                            return
                        }
                        
                        doc.name = name
                        
                        if let updateArgs = args as? UpdateDocumentArgs {
                            doc.id = updateArgs.id
                        }
                        
                        completion(.success(doc))
                    } else {
                        completion(.failure(.unkown))
                    }
                }
            }
        } else {
            if !args.isOnS3 {
                dict["data"] = content.base64EncodedString()
            }
            
            guard let name = dict.toJSON() else {
                completion(.failure(.unkown))
                return
            }
            
            doc.name = name
            
            if let updateArgs = args as? UpdateDocumentArgs {
                doc.id = updateArgs.id
            }
            
            completion(.success(doc))
        }
    }
}
