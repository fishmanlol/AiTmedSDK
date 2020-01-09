//
//  AiTmed+add.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import Alamofire

extension AiTmed {
    public static func createDocument(args: CreateDocumentArgs, completion: @escaping (Swift.Result<Document, AiTmedError>) -> Void) {
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let doc):
                //when success in creating doc, then decide whether need to upload to S3
                shared._createDoc(doc: doc, jwt: shared.c!.jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (doc, jwt)):
                        shared.c.jwt = jwt
                        let document = Document(doc)
                        if !args.isOnS3 {
                            completion(.success(document))
                        } else {
                            if let uploadURL = document.uploadURL {
                                Alamofire.upload(args.content, to: uploadURL, method: .put, headers: nil).responseString(completionHandler: { (r) in
                                    print("upload: \n \(uploadURL)")
                                    print(r.description)
                                    if let error = r.error {
                                        print("createDocument failed: \(error.localizedDescription)")
                                        completion(.failure(.unkown))
                                        return
                                    }
                                    
                                    switch r.result {
                                    case .failure(let error):
                                        print("error: ", error)
                                        completion(.failure(.unkown))
                                    case .success(let str):
                                        print("success: ", str)
                                        completion(.success(document))
                                    }
                                })
                            } else {
                                completion(.failure(.unkown))
                            }
                        }
                    }
                })
            }
        }
    }
    
    static func createEdge(args: CreateEdgeArgs, completion: @escaping (Swift.Result<Edge, AiTmedError>) -> Void) {
        var jwt: String = ""
        if let c = shared.c {
            jwt = c.jwt
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edge):
                shared._createEdge(edge: edge, jwt: jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (edge, jwt)):
                        shared.c.jwt = jwt
                        completion(.success(edge))
                    }
                })
            }
        }
    }
    
    static func createVertex(args: CreateVertexArgs, completion: @escaping (Swift.Result<Vertex, AiTmedError>) -> Void) {
        guard let jwt = shared.OPTCodeJwt[args.uid] else {
            completion(.failure(.unkown))
            return
        }
        
        shared.transform(args: args) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let vertex):
                shared._createVertex(vertex: vertex, jwt: jwt, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let (vertex, jwt)):
                        shared.c.jwt = jwt
                        completion(.success(vertex))
                    }
                })
            }
        }
    }
}

//MARK: - Transform
extension AiTmed {
    func transform(args: CreateEdgeArgs, completion: (Swift.Result<Edge, AiTmedError>) -> Void) {
        if let error = checkStatus() {
            completion(.failure(error))
            return
        }
        
        var edge = Edge()
        edge.type = args.type
        edge.name = args.name
        edge.stime = args.stime
        
        if let bivd = args.bvid {
            edge.bvid = bivd
        }
        
        if let besak = args.besak {
            edge.besak = besak
        }
        
        if let eesak = args.eesak {
            edge.eesak = eesak
        }
        
        completion(.success(edge))
    }
    
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
        
        if args.isEncrypt {
            AiTmed.xeskPairInEdge(args.folderID) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let keypair):
                    if let kp = keypair {
                        if !args.isOnS3 {
                            dict["data"] = content.base64EncodedString()
                        }
                        
                        guard let name = dict.toJSON() else {
                            completion(.failure(.unkown))
                            return
                        }
                        
                        doc.name = name
                        
                        if let updateArgs = args as? UpdateDocumentArgs {
                            doc.id = updateArgs.docID
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
                doc.id = updateArgs.docID
            }
            
            completion(.success(doc))
        }
    }
    
    func transform(args: CreateVertexArgs, completion: (Swift.Result<Vertex, AiTmedError>) -> Void) {
        var vertex = Vertex()
        vertex.type = AiTmedType.createUser
        vertex.tage = args.tage
        vertex.uid = args.uid
        vertex.pk = args.pk
        vertex.esk = args.esk
        completion(.success(vertex))
    }
 
}

//    var content = args.content
//    if args.isZipSatisfied {
//    content = args.content.zip() ?? Data()
//    }
//
//    if args.isEncrypt {
//
//    }
//
//    var dict: [String: Any] = ["title": args.title, "isOnS3": args.isOnS3, "isGzip": args.content.isZipSatisfied, "type": args.mime.rawValue]
//
//    if !args.isOnS3 {
//    dict["data"] = content.base64EncodedString()
//    }
//
//    guard let name = dict.toJSON() else {
//    completion(.failure(.unkown))
//    return
//    }
//
//    var doc = Doc()
//    doc.name = name
//    doc.eid = args.folderID
//    doc.type = args.type
//    //unit is byte
//    doc.size = Int32(args.content.count)
//
//    if let updateArgs = args as? UpdateDocumentArgs {
//        doc.id = updateArgs.docID
//    }
//
//    completion(.success(doc))
//}
