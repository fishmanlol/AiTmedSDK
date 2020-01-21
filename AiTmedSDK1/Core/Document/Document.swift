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
        
    }
    
    
    static func createDocument(args: CreateDocumentArgs, completion: @escaping (Swift.Result<Document, AiTmedError>) -> Void) {
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
    
    static func retrieveDocument(args: RetrieveDocArgs, completion: @escaping (Swift.Result<[Document], AiTmedError>) -> Void) {
        shared._retrieveDoc(args: args, jwt: shared.c.jwt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (docs, jwt)):
                shared.c.jwt = jwt
                var documents: [Document] = []
                let group = DispatchGroup()
                for var document in docs.map({ Document($0) }) {
                    group.enter()
                    
                    if document.isOnS3, let downloadURL = document.downloadURL {
                        Alamofire.download(downloadURL).responseData(completionHandler: { (response) in
                            print("download url: \(downloadURL)")
                            switch response.result {
                            case .failure(let error):
                                document.isBroken = true
                            case .success(let data):
                                if document.isZipped {
                                    document.content = data.unzip()
                                } else {
                                    document.content = data
                                }
                            }
                            
                            documents.append(document)
                            group.leave()
                        })
                    } else {
                        documents.append(document)
                        group.leave()
                    }
                }
                
                group.notify(queue: DispatchQueue.main, execute: {
                    print("documents----------------------------------", documents)
                    completion(.success(documents))
                })
            }
        }
    }
    
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
