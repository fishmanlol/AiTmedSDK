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
            firstly { () -> Promise<(Doc, Data)> in
                shared.transform(args: args)//transform arguments to Doc object which will used to be create
            }.then { (_doc, data) -> Promise<((URL, Data)?, Document)> in
                return Promise<((URL, Data)?, Document)> { resolver2 in
                    shared.g.createDoc(doc: _doc, jwt: shared.c.jwt, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            resolver2.reject(error)
                        case .success(let (doc, jwt)):
                            shared.c.jwt = jwt
                            
                            let documentType = DocumentType(value: UInt32(doc.type))
                            let document = Document(id: doc.id, folderID: doc.eid, title: args.title, content: data, isBroken: false, mediaType: args.mediaType, type: documentType, mtime: doc.mtime, ctime: doc.ctime)
                            
                            if documentType.isOnServer {
                                resolver2.fulfill((nil, document))
                            } else {//on S3
                                //unwrap deat
                                if let dict = doc.deat.toJSONDict(),
                                    let urlString = dict["url"] as? String,
                                    let sig = dict["sig"] as? String,
                                    let url = URL(string: urlString + "?" + sig),
                                    let _ = dict["exptime"] as? String {
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
        return Promise<[Document]> { resolver in
            shared.g.retrieveDoc(args: args, jwt: shared.c.jwt, completion: { (result) in
                switch result {
                case .failure(let error):
                    resolver.reject(error)
                    return
                case .success(let (docs, jwt)):
                    shared.c.jwt = jwt
                    var documents: [Document] = []
                    var success = true
                    let group = DispatchGroup()
                    
                    for doc in docs {
                        group.enter()
                        
                        DispatchQueue.global().async {
                            defer {
                                print("defer leave")
                                group.leave() }
                            
                            let documentType = DocumentType(value: UInt32(doc.type))
                            
                            var title = ""
                            var unprocceedData = Data()
                            var mediaType: MediaType = .other
                            
                            if let nameDict = doc.name.toJSONDict(),
                                let t = nameDict["title"] as? String {
                                title = t
                            }
                            
                            if documentType.isOnServer {
                                if let nameDict = doc.name.toJSONDict(),
                                    let d = nameDict["data"] as? String,
                                    let dd = Data(base64Encoded: d),
                                    let mt = nameDict["type"] as? String,
                                    let _mediaType = MediaType(rawValue: mt) {
                                    unprocceedData = dd
                                    mediaType = _mediaType
                                } else {
                                    success = false
                                }
                            } else {
                                if let deatDict = doc.deat.toJSONDict(),
                                    let urlString = deatDict["url"] as? String {
                                    let sem = DispatchSemaphore(value: 0)
                                    Alamofire.download(urlString).responseData(completionHandler: { (response) in
                                        print("download url: \(urlString)")
                                        switch response.result {
                                        case .failure(let error):
                                            success = false
                                        case .success(let data):
                                            unprocceedData = data
                                            
                                            if !documentType.isBinary {
                                                if let base64 = String(data: unprocceedData, encoding: .utf8), let d = Data(base64Encoded: base64) {
                                                    unprocceedData = d
                                                } else {
                                                    success = false
                                                }
                                            }
                                        }
                                        sem.signal()
                                    })
                                    sem.wait()
                                } else {
                                    success = false
                                    return
                                }
                            }
                            
                            guard success else { return }
                            
                            if documentType.isEncrypt {
                                let result = AiTmed.xeskPairInEdge(args.folderID)
                                
                                switch result {
                                case .failure(let error):
                                    success = false
                                    return
                                case .success(let keypair):
                                    if let kp = keypair {
                                        let (besak, _) = kp
                                        if let sak = shared.e.generateSAK(xesak: besak, sendPublicKey: shared.c.pk, recvSecretKey: shared.c.sk!) {
            
                                            if let decryptedData = shared.e.sKeyDecrypt(secretKey: sak, data: [UInt8](unprocceedData)) {
                                                print("decrpted success")
                                                unprocceedData = Data(decryptedData)
                                            } else {
                                                print("decrypted failed")
                                                success = false
                                                return
                                            }
                                        } else {
                                            success = false
                                            return
                                        }
                                    }
                                }
                            }
                            
                            if documentType.isZipped {
                                if let unzipped = unprocceedData.unzip() {
                                    unprocceedData = unzipped
                                } else {
                                    success = false
                                    return
                                }
                            }
                            
                            let document = Document(id: doc.id, folderID: doc.eid, title: title, content: unprocceedData, isBroken: false, mediaType: mediaType, type: documentType, mtime: doc.mtime, ctime: doc.ctime)
                            documents.append(document)
                        }
                    }
                    
                    group.notify(queue: DispatchQueue.global(), execute: {
                        if success {
                            resolver.fulfill(documents)
                        } else {
                            resolver.reject(AiTmedError.unkown)
                        }
                    })
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
