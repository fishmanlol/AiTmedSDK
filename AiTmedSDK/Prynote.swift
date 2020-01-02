//
//  Prynote.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation


extension AiTmed {
    public class Prynote {
        
        public static func retrieveNotebooks(args: RetrieveNotebooksArgs, completion: @escaping (Result<[Notebook], AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let retrieveEdgeArgs):
                    shared._retreiveEdge(args: retrieveEdgeArgs, jwt: shared.c!.jwt, completion: { (result: Result<([Edge], String), AiTmedError>) in
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
        
        public static func createNoteBook(args: CreateNotebookArgs, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let edge):
                    shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
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
        
        public static func updateNotebook(args: UpdateNotebookArgs, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
            shared.transform(args: args) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(var edge):
                    edge.id = args.id
                    shared._createEdge(edge: edge, jwt: shared.c!.jwt, completion: { (result: Result<(Edge, String), AiTmedError>) in
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
    }
}
