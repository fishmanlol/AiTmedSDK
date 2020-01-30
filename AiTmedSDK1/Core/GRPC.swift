//
//  GRPC.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//
import Foundation
import PromiseKit


class GRPC {
    let grpcTimeout: TimeInterval = 5
    let host = "testapi2.aitmed.com:443"
    let cache = Cache<Data, Any>(entryLifetime: 2, maximumEntryCount: Int.max)
    lazy var client: Aitmed_Ecos_V1beta1_EcosAPIServiceClient = {
        let c = Aitmed_Ecos_V1beta1_EcosAPIServiceClient(address: host, secure: true)
        c.timeout = grpcTimeout
        return c
    }()
    
    ///async, create edge: pass out jwt
    func createEdge(edge: Edge, jwt: String, completion: @escaping (Swift.Result<(Edge, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("create edge name: ", edge.name)
        print("create edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.ce(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("create edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("Create edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    cache?[response.edge.id] = response.edge
                    completion(.success((response.edge, response.jwt)))
                } else if response.code == 1020 {
                    completion(.failure(.apiResultFailed(.userNotExist)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    //sync, create edge: pass out jwt
    func createEdge(edge: Edge, jwt: String) throws -> (Edge, String) {
        var request = Aitmed_Ecos_V1beta1_ceReq()
        request.edge = edge
        request.jwt = jwt
        
        print("create edge name: ", edge.name)
        print("create edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.ce(request)
            
            if response.code == 0 {
                cache[response.edge.id] = response.edge
                return (response.edge, response.jwt)
            } else if response.code == 1020 {
                throw AiTmedError.apiResultFailed(.userNotExist)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
    
    //promise, create edge: pass out jwt
    func createEdge(edge: Edge, jwt: String) -> Promise<(Edge, String)> {
        return Promise<(Edge, String)> { resolver in
            var request = Aitmed_Ecos_V1beta1_ceReq()
            request.edge = edge
            request.jwt = jwt
            print("create edge name: ", edge.name)
            print("create edge request json: \n", (try? request.jsonString()) ?? "")
            
            do {
                try client.ce(request) { [weak cache] (response, result) in
                    guard let response = response else {
                        print("create edge has no response(\(result.statusCode)): \(result.description)")
                        resolver.reject(AiTmedError.grpcFailed(.unkown))
                        return
                    }
                    
                    print("Create edge response: \n", (try? response.jsonString()) ?? "")
                    
                    if response.code == 0 {
                        cache?[response.edge.id] = response.edge
                        resolver.fulfill((response.edge, response.jwt))
                    } else if response.code == 1020 {
                        resolver.reject(AiTmedError.apiResultFailed(.userNotExist))
                    } else if response.code == 113 {
                        resolver.reject(AiTmedError.credentialFailed(.JWTExpired(response.jwt)))
                    } else {
                        resolver.reject(AiTmedError.apiResultFailed(.unkown))
                    }
                }
            } catch {
                print("grpc error: \(error.localizedDescription)")
                resolver.reject(AiTmedError.grpcFailed(.unkown))
            }
        }
    }
    
    ///async, retreive edge
    func retreiveEdges(args: RetrieveArgs, jwt: String, completion: @escaping (Swift.Result<([Edge], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.id = args.ids
        request.objType = ObjectType.edge.code
        request.jwt = jwt
        request.xfname = args.xfname
        
        if let type = args.type {
            request.type = type
        }
        
        if let maxCount = args.maxCount {
            request.maxcount = maxCount
        }
        
        print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.re(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("retrieve edge has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    response.edge.forEach { cache?[$0.id] = $0 }
                    completion(.success((response.edge, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///sync, retrieve edge
    func retrieveEdges(args: RetrieveArgs, jwt: String) throws -> ([Edge], String) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.id = args.ids
        request.objType = ObjectType.edge.code
        request.jwt = jwt
        request.xfname = "bvid"
        
        if let type = args.type {
            request.type = type
        }
        
        if let maxCount = args.maxCount {
            request.maxcount = maxCount
        }
        
        print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.re(request)
            
            print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
            
            if response.code == 0 {
                response.edge.forEach { cache[$0.id] = $0 }
                return (response.edge, response.jwt)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
    
    ///promise, retreive edge
    func retreiveEdges(args: RetrieveArgs, jwt: String) -> Promise<([Edge], String)> {
        return Promise<([Edge], String)> { resolver in
            var request = Aitmed_Ecos_V1beta1_rxReq()
            request.id = args.ids
            request.objType = ObjectType.edge.code
            request.jwt = jwt
            request.xfname = args.xfname
            
            
            if let type = args.type {
                request.type = type
            }
            
            if let maxCount = args.maxCount {
                request.maxcount = maxCount
            }
            
            print("retreive edge request json: \n", (try? request.jsonString()) ?? "")
            
            do {
                try client.re(request) { [weak cache] (response, result) in
                    guard let response = response else {
                        print("retrieve edge has no response(\(result.statusCode)): \(result.description)")
                        resolver.reject(AiTmedError.grpcFailed(.unkown))
                        return
                    }
                    
                    print("retrieve edge response: \n", (try? response.jsonString()) ?? "")
                    
                    if response.code == 0 {
                        response.edge.forEach { cache?[$0.id] = $0 }
                        resolver.fulfill((response.edge, response.jwt))
                    } else if response.code == 113 {
                        resolver.reject(AiTmedError.credentialFailed(.JWTExpired(response.jwt)))
                    } else {
                        resolver.reject(AiTmedError.apiResultFailed(.unkown))
                    }
                }
            } catch {
                print("grpc error: \(error.localizedDescription)")
                resolver.reject(AiTmedError.grpcFailed(.unkown))
            }
        }
    }
    
    ///async
    func delete(ids: [Data], jwt: String, completion: @escaping (Swift.Result<String, AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        request.jwt = jwt
        
        print("delete request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.dx(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("delete has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("delete response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    cache?.removeValues(forKeys: ids)
                    completion(.success(response.jwt))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///sync
    func delete(ids: [Data], jwt: String) throws -> (Void, String) {
        var request = Aitmed_Ecos_V1beta1_dxReq()
        request.id = ids
        request.jwt = jwt
        
        print("delete request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.dx(request)
            
            print("delete response: \n", (try? response.jsonString()) ?? "")
            
            if response.code == 0 {
                cache.removeValues(forKeys: ids)
                return  ((), response.jwt)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
    
    ///promise
    func delete(ids: [Data], jwt: String) -> Promise<(Void, String)> {
        return Promise<(Void, String)> { resolver in
            var request = Aitmed_Ecos_V1beta1_dxReq()
            request.id = ids
            request.jwt = jwt
            
            print("delete request json: \n", (try? request.jsonString()) ?? "")
            
            do {
                try client.dx(request) { [weak cache] (response, result) in
                    guard let response = response else {
                        print("delete has no response(\(result.statusCode)): \(result.description)")
                        resolver.reject(AiTmedError.grpcFailed(.unkown))
                        return
                    }
                    
                    print("delete response: \n", (try? response.jsonString()) ?? "")
                    
                    if response.code == 0 {
                        cache?.removeValues(forKeys: ids)
                        resolver.fulfill(((), response.jwt))
                    } else if response.code == 113 {
                        resolver.reject(AiTmedError.credentialFailed(.JWTExpired(response.jwt)))
                    } else {
                        resolver.reject(AiTmedError.apiResultFailed(.unkown))
                    }
                }
            } catch {
                print("grpc error: \(error.localizedDescription)")
                resolver.reject(AiTmedError.grpcFailed(.unkown))
            }
        }
    }
    
    ///async, create vertex: pass out jwt
    func createVertex(vertex: Vertex, jwt: String, completion: @escaping (Swift.Result<(Vertex, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cvReq()
        request.vertex = vertex
        request.jwt = jwt
        
        print("create vertex request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cv(request, completion: { [weak cache] (response, result) in
                guard let response = response else {
                    print("create vertex has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("create vertex response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    cache?[vertex: response.vertex.id] = response.vertex
                    completion(.success((response.vertex, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            })
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///sync, create vertex: pass out jwt
    func createVertex(vertex: Vertex, jwt: String) throws -> (Vertex, String) {
        var request = Aitmed_Ecos_V1beta1_cvReq()
        request.vertex = vertex
        request.jwt = jwt
        
        print("create vertex request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.cv(request)
            
            print("create vertex response: \n", (try? response.jsonString()) ?? "")
            
            if response.code == 0 {
                cache[vertex: response.vertex.id] = response.vertex
                return (response.vertex, response.jwt)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
    
    ///async, create doc
    func createDoc(doc: Doc, jwt: String, completion: @escaping (Swift.Result<(Doc, String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_cdReq()
        request.doc = doc
        request.jwt = jwt
        
        print("create doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.cd(request, completion: { [weak cache] (response, result) in
                guard let response = response else {
                    print("create doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("create doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    cache?[doc: response.doc.id] = response.doc
                    completion(.success((response.doc, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            })
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///sync, create doc
    func createDoc(doc: Doc, jwt: String) throws -> (Doc, String) {
        var request = Aitmed_Ecos_V1beta1_cdReq()
        request.doc = doc
        request.jwt = jwt
        
        print("create doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.cd(request)
            
            print("create doc response: \n", (try? response.jsonString()) ?? "")
            
            if response.code == 0 {
                cache[doc: response.doc.id] = response.doc
                return (response.doc, response.jwt)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
    
    ///async
    func retrieveDoc(args: RetrieveDocArgs, jwt: String, completion: @escaping (Swift.Result<([Doc], String), AiTmedError>) -> Void) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.jwt = jwt
        request.objType = ObjectType.doc.code
        request.id = [args.folderID]
        request.xfname = "eid"
        
        print("retreive doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            try client.rd(request) { [weak cache] (response, result) in
                guard let response = response else {
                    print("retrieve doc has no response(\(result.statusCode)): \(result.description)")
                    completion(.failure(.grpcFailed(.unkown)))
                    return
                }
                
                print("retrieve doc response: \n", (try? response.jsonString()) ?? "")
                
                if response.code == 0 {
                    response.doc.forEach { cache?[doc: $0.id] = $0 }
                    completion(.success((response.doc, response.jwt)))
                } else if response.code == 113 {
                    completion(.failure(.credentialFailed(.JWTExpired(response.jwt))))
                } else {
                    completion(.failure(.apiResultFailed(.unkown)))
                }
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            completion(.failure(.grpcFailed(.unkown)))
        }
    }
    
    ///sync
    func retrieveDoc(args: RetrieveDocArgs, jwt: String) throws -> ([Doc], String) {
        var request = Aitmed_Ecos_V1beta1_rxReq()
        request.jwt = jwt
        request.objType = ObjectType.doc.code
        request.id = [args.folderID]
        request.xfname = "eid"
        
        print("retreive doc request json: \n", (try? request.jsonString()) ?? "")
        
        do {
            let response = try client.rd(request)
            
            print("retrieve doc response: \n", (try? response.jsonString()) ?? "")
            
            if response.code == 0 {
                response.doc.forEach { cache[doc: $0.id] = $0 }
                return (response.doc, response.jwt)
            } else if response.code == 113 {
                throw AiTmedError.credentialFailed(.JWTExpired(response.jwt))
            } else {
                throw AiTmedError.apiResultFailed(.unkown)
            }
        } catch {
            print("grpc error: \(error.localizedDescription)")
            throw AiTmedError.grpcFailed(.unkown)
        }
    }
}
