//
//  Prynote.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import Alamofire

extension AiTmed {
    public class Prynote {
        
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
        
        public static func retrieveDocument(args: RetrieveDocArgs, completion: @escaping (Swift.Result<[Document], AiTmedError>) -> Void) {
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
                            group.leave()
                        }
                    }

                    group.notify(queue: DispatchQueue.main, execute: {
                        completion(.success(documents))
                    })
                }
            }
        }
        
        public static func retrieveNotebooks(args: RetrieveNotebooksArgs, completion: @escaping (Swift.Result<[Notebook], AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let retrieveEdgeArgs):
                    shared._retreiveEdge(args: retrieveEdgeArgs, jwt: shared.c!.jwt, completion: { (result: Swift.Result<([Edge], String), AiTmedError>) in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let (edges, jwt)):
                            shared.c?.jwt = jwt
                            var notebooks: [Notebook] = []
                            for edge in edges {
                                var title = ""
                                if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                                    title = t
                                }
                                let notebook = Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty)
                                notebooks.append(notebook)
                            }
                            completion(.success(notebooks))
                        }
                    })
                }
            }
        }
        
        public static func createNoteBook(args: CreateNotebookArgs, completion: @escaping (Swift.Result<Notebook, AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let edge):
                    shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Swift.Result<(Edge, String), AiTmedError>) in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let (edge, jwt)):
                            shared.c?.jwt = jwt
                            var title = ""
                            if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                                title = t
                            }
                            completion(.success(Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty)))
                        }
                    })
                }
            }
        }
        
        public static func updateNotebook(args: UpdateNotebookArgs, completion: @escaping (Swift.Result<Notebook, AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(var edge):
                    edge.id = args.id
                    shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Swift.Result<(Edge, String), AiTmedError>) in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let (edge, jwt)):
                            shared.c?.jwt = jwt
                            var title = ""
                            if let dict = edge.name.toJSONDict(), let t = dict["title"] as? String {
                                title = t
                            }
                            completion(.success(Notebook(id: edge.id, title: title, isEncrypt: !edge.besak.isEmpty)))
                        }
                    })
                }
            }
        }
        
        public static func removeNotebook(id: Data, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
            //first find out all notes
            shared._retrieveDoc(args: RetrieveDocArgs(folderID: id), jwt: shared.c.jwt) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let (docs, jwt)):
                    shared.c.jwt = jwt
                    var success = true
                    for doc in docs {
                        let (jwt, error) = shared._delete(ids: [doc.id], jwt: shared.c.jwt)
                        if let j = jwt, error == nil {
                            print("222")
                            shared.c.jwt = j
                        } else {
                            print("111")
                            success = false
                            break
                        }
                    }
                    
                    if success {
                        let (jwt, error) = shared._delete(ids: [id], jwt: shared.c.jwt)
                        if let j = jwt, error == nil {
                            shared.c.jwt = j
                            completion(.success(()))
                        } else {
                            completion(.failure(.unkown))
                        }
                    } else {
                        completion(.failure(.unkown))
                    }
                }
            }
        }
    }
}
