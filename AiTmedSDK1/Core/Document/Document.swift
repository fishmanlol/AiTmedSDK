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
        return Promise<Document> { resolver1 in
            firstly { () -> Promise<(Doc, Data, Bool, Bool)> in
                shared.transform(args: args)//transform arguments to Doc object which will used to be create
            }.then { (doc, data, isOnServer, isZipped) -> Promise<((URL, Data)?, Document)> in
                return Promise<((URL, Data)?, Document)> { resolver2 in
                    shared.g.createDoc(doc: doc, jwt: shared.c.jwt, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            resolver2.reject(error)
                        case .success(let (doc, jwt)):
                            shared.c.jwt = jwt
                            
                            let document = Document(id: doc.id, folderID: args.folderID, title: args.title, content: data, isBroken: false, isOnServer: isOnServer, isZipped: isZipped, isBinary: args.isBinary, isEncrypted: args.isEncrypt, isExtraKeyNeeded: args.isExtraKeyNeeded, isInvitable: args.isInvitable, isEditable: args.isEditable, isViewable: args.isViewable)
                            
                            if isOnServer {
                                resolver2.fulfill((nil, document))
                            } else {//on S3
                                //unwrap deat
                                if let dict = doc.deat.toJSONDict(),
                                    let urlString = dict["url"] as? String,
                                    let sig = dict["sig"] as? String,
                                    let url = URL(string: urlString + "?" + sig),
                                    let _ = dict["exptime"] as? Int64 {
                                    resolver2.fulfill(((url, data), document))
                                } else {
                                    print("create document deat parse error")
                                    resolver2.reject(AiTmedError.unkown)
                                }
                            }
                        }
                    })
                }
            }.then ({ (uploadInfo, document) -> Promise<Document> in //upload or not
                if let info = uploadInfo {//we need upload
                    let (url, data) = info
                    return Promise<Document> { resolver3 in
                        Alamofire.upload(data, to: url, method: .put, headers: nil).responseString(completionHandler: { (r) in
                            print("upload: \n \(url)")
                            print(r.description)
                            if let error = r.error {
                                print("createDocument failed: \(error.localizedDescription)")
                                resolver3.reject(error)
                                return
                            }
                            
                            switch r.result {
                            case .failure(let error):
                                print("error: ", error)
                                resolver3.reject(AiTmedError.unkown)
                            case .success(let str):
                                print("success: ", str)
                                resolver3.fulfill(document)
                            }
                        })
                    }
                } else {//we don't need upload
                    return Promise.value(document)
                }
            }).done({ (document) in
                resolver1.fulfill(document)
            }).catch({ (error) in
                print("create document error: \(error.localizedDescription)")
                resolver1.reject(error)
            })
        }
    }
    
    
//    static func createDocument(args: CreateDocumentArgs, completion: @escaping (Swift.Result<Document, AiTmedError>) -> Void) {
//        shared.transform(args: args) { (result) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let doc):
//                //when success in creating doc, then decide whether need to upload to S3
//                shared._createDoc(doc: doc, jwt: shared.c!.jwt, completion: { (result) in
//                    switch result {
//                    case .failure(let error):
//                        completion(.failure(error))
//                    case .success(let (doc, jwt)):
//                        shared.c.jwt = jwt
//                        let document = Document(doc)
//                        if !args.isOnS3 {
//                            completion(.success(document))
//                        } else {
//                            if let uploadURL = document.uploadURL {
//                                Alamofire.upload(args.content, to: uploadURL, method: .put, headers: nil).responseString(completionHandler: { (r) in
//                                    print("upload: \n \(uploadURL)")
//                                    print(r.description)
//                                    if let error = r.error {
//                                        print("createDocument failed: \(error.localizedDescription)")
//                                        completion(.failure(.unkown))
//                                        return
//                                    }
//
//                                    switch r.result {
//                                    case .failure(let error):
//                                        print("error: ", error)
//                                        completion(.failure(.unkown))
//                                    case .success(let str):
//                                        print("success: ", str)
//                                        completion(.success(document))
//                                    }
//                                })
//                            } else {
//                                completion(.failure(.unkown))
//                            }
//                        }
//                    }
//                })
//            }
//        }
//    }
    
    static func retrieveDocuments(args: RetrieveDocArgs) -> Promise<[Document]> {
        return Promise<[Document]> { resolver in
            shared.g.retrieveDoc(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                case .success(let (docs, jwt)):
                    shared.c.jwt = jwt
                    var documents: [Document] = []
                    let group = DispatchGroup()
                    
                    for doc in docs {
                        group.enter()
                        
                        DispatchQueue.global().async {
                            let isOnServer = doc.type.isSet(0)
                            let isZipped = doc.type.isSet(1)
                            let isBinary = doc.type.isSet(2)
                            let isEncrypt = doc.type.isSet(3)
                            let isExtraKeyNeeded = doc.type.isSet(4)
                            let isInvitable = doc.type.isSet(24)
                            let isEditable = doc.type.isSet(25)
                            let isViewable = doc.type.isSet(26)
                            var mediaType: MediaType = .other
                            var title = ""
                            var unprocceedData = Data()
                            var isBroken = false
                            
                            if let nameDict = doc.name.toJSONDict(),
                                let t = nameDict["title"] as? String,
                                let mimeString = nameDict["type"] as? String,
                                let mime = MediaType(rawValue: mimeString) {
                                mediaType = mime
                                title = t
                            }
                            
                            if isOnServer {
                                if let nameDict = doc.name.toJSONDict(),
                                    let d = nameDict["data"] as? String,
                                    let dd = Data(base64Encoded: d) {
                                    unprocceedData = dd
                                } else {
                                    isBroken = true
                                }
                                
                                group.leave()
                            } else {
                                if let deatDict = doc.deat.toJSONDict(),
                                    let urlString = deatDict["url"] as? String {
                                    let sem = DispatchSemaphore(value: 0)
                                    Alamofire.download(urlString).responseData(completionHandler: { (response) in
                                        print("download url: \(urlString)")
                                        switch response.result {
                                        case .failure(let error):
                                            isBroken = true
                                        case .success(let data):
                                            unprocceedData = data
                                        }
                                        sem.signal()
                                        group.leave()
                                    })
                                    sem.wait()
                                } else {
                                    isBroken = true
                                    group.leave()
                                }
                            }
                            
                            if isEncrypt {
                                let keypair = AiTmed.xeskPairInEdge(args.folderID)
                
                                
                            }
                            
                            
                        }
                        
                        
                        
//                        if isOnServer {
//                            var content = Data()
//                            if let dict = doc.deat.toJSONDict(),
//                                let embedBase64 = dict["data"] as? String,
//                                let embedData = Data(base64Encoded: embedBase64) {
//                                content = embedData
//                            }
//                        } else {
//                            if let dict
//                            Alamofire.download(<#T##url: URLConvertible##URLConvertible#>)
//                        }
                        
//                        let document = Document(id: doc.id, folderID: doc.fid, title: title, content: <#T##Data#>, isBroken: <#T##Bool#>, isOnServer: <#T##Bool#>, isZipped: <#T##Bool#>, isBinary: <#T##Bool#>, isEncrypted: <#T##Bool#>, isExtraKeyNeeded: <#T##Bool#>, isInvitable: <#T##Bool#>, isEditable: <#T##Bool#>, isViewable: <#T##Bool#>)
                    }
                }
            })
        }
    }
    
//    static func retrieveDocument(args: RetrieveDocArgs, completion: @escaping (Swift.Result<[Document], AiTmedError>) -> Void) {
//        shared._retrieveDoc(args: args, jwt: shared.c.jwt) { (result) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let (docs, jwt)):
//                shared.c.jwt = jwt
//                var documents: [Document] = []
//                let group = DispatchGroup()
//                for var document in docs.map({ Document($0) }) {
//                    group.enter()
//
//                    if document.isOnS3, let downloadURL = document.downloadURL {
//                        Alamofire.download(downloadURL).responseData(completionHandler: { (response) in
//                            print("download url: \(downloadURL)")
//                            switch response.result {
//                            case .failure(let error):
//                                document.isBroken = true
//                            case .success(let data):
//                                if document.isZipped {
//                                    document.content = data.unzip()
//                                } else {
//                                    document.content = data
//                                }
//                            }
//
//                            documents.append(document)
//                            group.leave()
//                        })
//                    } else {
//                        documents.append(document)
//                        group.leave()
//                    }
//                }
//
//                group.notify(queue: DispatchQueue.main, execute: {
//                    print("documents----------------------------------", documents)
//                    completion(.success(documents))
//                })
//            }
//        }
//    }
    
//    static func deleteDocument(args: DeleteArgs, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
//        guard let c = shared.c, c.status == .login else {
//            completion(.failure(.credentialFailed(.credentialNeeded)))
//            return
//        }
//
//        shared._delete(ids: [args.id], jwt: shared.c!.jwt) { (result: Swift.Result<String, AiTmedError>) in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success(let jwt):
//                shared.c.jwt = jwt
//                completion(.success(()))
//            }
//        }
//    }
    
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
