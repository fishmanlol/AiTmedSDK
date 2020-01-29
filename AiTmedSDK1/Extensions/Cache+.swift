//
//  CacheUtil+.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/28/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension Cache {
    //edge
    subscript(edge edge: Data) -> Edge? {
        get {
            fatalError()
        }
        
        set {
            fatalError()
        }
    }
    
    subscript(edges edges: [Data]) -> [Edge]? {
        get {
            fatalError()
        }
        
        set {
            fatalError()
        }
    }
    
    //vertex
    subscript(vertex vertex: Data) -> Vertex? {
        get {
            fatalError()
        }
        
        set {
            fatalError()
        }
    }
    

    //doc
    subscript(doc doc: Data) -> Doc? {
        get {
            fatalError()
        }
        
        set {
            fatalError()
        }
    }
    
    subscript(docs docs: [Data]) -> [Doc]? {
        get {
            fatalError()
        }
        
        set {
            fatalError()
        }
    }
    
    func removeValues(forKeys keys: [Key]) {
        keys.forEach { removeValue(forKey: $0) }
    }
}
