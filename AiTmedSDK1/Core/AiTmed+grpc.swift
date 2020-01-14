//
//  AiTmed+grpc.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    ///Create edge: pass out jwt
    func _createEdge(edge: Edge, jwt: String, completion: @escaping (Swift.Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("create edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { (response, result) in
                guard let response = response else {
                    print("create edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("Create edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else if response.code == 1020 {
                    completion(.failure(.apiResultFailed(.userNotExist)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Retreive edge
    func _retreiveEdges(args: RetrieveEdgesArgs, jwt: String, completion: @escaping (Swift.Result<([Edge], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.id = args.ids
        request.objType = ObjectType.edge.code
        request.jwt = jwt
        request.type = args.type
        request.type = args.type
        request.xfname = "bvid"
        if let maxCount = args.maxCount {
            request.maxcount = maxCount
        }
        
        print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.re(request) { (response, result) in
                guard let response = response else {
                    print("retrieve edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    func _delete(ids: [Data], jwt: String, completion: @escaping (Swift.Result<String, AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        request.jwt = jwt
        
        print("delete request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.dx(request) { (response, result) in
                guard let response = response else {
                    print("delete has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("delete response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success(response.jwt))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
        print("11111")
    }
    
    ///sync
    func _delete(ids: [Data], jwt: String) -> (String?, AiTmedError?) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        request.jwt = jwt
        
        print("delete request json1: \n", (try? request.jsonString()) ?? "")
        
        guard let response = try? client.dx(request) else {
            print("delete request failed")
            return (nil, .unkown)
        }
        
        print("delete response: \n", (try? response.jsonString()) ?? "")
        
        guard response.code == 0 else {
            return (nil, .unkown)
        }
        
        return (response.jwt, nil)
    }
    
    ///Update edge
    func _updateEdge(edge: Edge, jwt: String, completion: @escaping (Swift.Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("update edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { (response, result) in
                guard let response = response else {
                    print("update edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("update edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.edge, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Create vertex: pass out jwt
    func _createVertex(vertex: Vertex, jwt: String, completion: @escaping (Swift.Result<(Vertex, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cvReq()
        request.vertex = vertex
        request.jwt = jwt
        
        print("create vertex request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cv(request, completion: { (response, result) in
                guard let response = response else {
                    print("create vertex has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("create vertex response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.vertex, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            })
        } catch {
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///Create doc
    func _createDoc(doc: Doc, jwt: String, completion: @escaping (Swift.Result<(Doc, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cdReq()
        request.doc = doc
        request.jwt = jwt
        
        print("create doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cd(request, completion: { (response, result) in
                guard let response = response else {
                    print("create doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("create doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.doc, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            })
        } catch {
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    func _retrieveDoc(args: RetrieveDocArgs, jwt: String, completion: @escaping (Swift.Result<([Doc], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.jwt = jwt
        request.objType = ObjectType.doc.code
        request.id = [args.folderID]
        request.xfname = "eid"
        
        print("retreive doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.rd(request) { (response, result) in
                guard let response = response else {
                    print("retrieve doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("retrieve doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    completion(.success((response.doc, response.jwt)))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
}
