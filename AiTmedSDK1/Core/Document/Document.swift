//
//  Document.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

extension AiTmed {
    //MARK: - Create
    static func createDocument(args: CreateDocumentArgs) -> Promise<Document> {
        return DispatchQueue.global().async(.promise, execute: { () -> Document in
            var content = args.content
            
            let _ = try checkStatus().wait()//check status
            print("before zip: ", [UInt8](args.content))
            if args.isZipped {//zip
                content = try zip(args.content).wait()
                print("create zipped:", [UInt8](content))
            }
            
            if args.isEncrypt {//encrypt
                let besak = try besakInEdge(args.folderID).wait()
                let sak = try getSak(besak: besak, sendPK: shared.c.pk, recvSK: shared.c.sk!).wait()
                content = try encrypt(content, sak: sak).wait()
                print("create encrypt:", [UInt8](args.content))
            }
            
            if !args.isBinary {//base64
                content = content.base64EncodedData()
            }
            
            //compose name
            var dict: [String: Any] = ["title": args.title, "type": args.mediaType.rawValue]
            if args.isOnServer {//if data store on server
                dict["data"] = String(bytes: content, encoding: .utf8)
            }
            
            let name = try dict.toJSON().wait()
            
            //create type
            let type = DocumentType.initWithArgs(args: args)
            
            //create doc
            var _doc = Doc()
            _doc.name = name
            _doc.type = Int32(type.value)
            _doc.eid = args.folderID
            _doc.size = Int32(content.count)
            let (doc, jwt) = try shared.g.createDoc(doc: _doc, jwt: shared.c.jwt)
            shared.c.jwt = jwt
            
            if !args.isOnServer {//if the data store on S3
                let deat = try doc.deat.toJSONDict().wait()
                guard let urlString = deat["url"] as? String,
                        let sig = deat["sig"] as? String,
                        let _ = deat["exptime"] as? String else {
                        throw AiTmedError.unkown
                }
                
                //compose upload url: 'url' + ? + 'sig'
                let uploadURL = urlString + "?" + sig
                print("upload url: \(uploadURL)")
                try upload(content, to: uploadURL).wait()
                print("upload success!")
            }
            
            return Document(id: doc.id, folderID: doc.eid, title: args.title, content: args.content, isBroken: false, mediaType: args.mediaType, type: type, mtime: doc.mtime, ctime: doc.ctime)
        })
    }
    
    static func retrieveDoc(args: RetrieveDocArgs) -> Promise<[Doc]> {
        return Promise<[Doc]> { resolver in
            shared.g.retrieveDoc(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let (docs, jwt)):
                    shared.c.jwt = jwt
                    resolver.fulfill(docs)
                }
            })
        }
    }
    
    static func retrieveDocuments(args: RetrieveDocArgs) -> Promise<[Document]> {
        return DispatchQueue.global().async(.promise) { () -> [Document] in
            let docs = try retrieveDoc(args: args).wait()
            let documentPromises = docs.map { Document.initWithDoc($0) }
            return try when(fulfilled: documentPromises).wait()
        }
    }
    
    static func updateDocument(args: UpdateDocumentArgs) -> Promise<Document> {
        return Promise<Document> { resolver in
            firstly { () -> Promise<Void> in
                deleteDocument(args: DeleteArgs(id: args.id))
            }.then { (_) -> Promise<Document> in
                createDocument(args: args)
            }.done { (document) -> Void in
                resolver.fulfill(document)
            }.catch { (error) -> Void in
                resolver.reject(error)
            }
        }
    }
    
    static func deleteDocument(args: DeleteArgs) -> Promise<Void> {
        return Promise<Void> { resolver in
            if let error = shared.checkStatus() {
                resolver.reject(error)
                return
            }
            
            shared.g.delete(ids: [args.id], jwt: shared.c.jwt) { (result: Swift.Result<String, AiTmedError>) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let jwt):
                    shared.c.jwt = jwt
                    resolver.fulfill(())
                }
            }
        }
    }
}
