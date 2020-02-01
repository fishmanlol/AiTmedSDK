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
            return self[edge as! Key] as? Edge
        }
        
        set {
            self[edge as! Key] = newValue as? Value
        }
    }
    
    //vertex
    subscript(vertex vertex: Data) -> Vertex? {
        get {
            return self[vertex as! Key] as? Vertex
        }
        
        set {
            self[vertex as! Key] = newValue as? Value
        }
    }
    

    //doc
    subscript(doc doc: Data) -> Doc? {
        get {
            return self[doc as! Key] as? Doc
        }
        
        set {
            self[doc as! Key] = newValue as? Value
        }
    }
    
    func removeValues(forKeys keys: [Key]) {
        keys.forEach { removeValue(forKey: $0) }
    }
}
