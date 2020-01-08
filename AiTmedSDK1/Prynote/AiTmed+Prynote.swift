//
//  AiTmed+Prynote.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/7/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Note
    public static func updateNote(id: Data, notebookID: Data, title: String?, content: Data?, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        
    }
    
    public static func addNote(title: String, content: Data, isEncrypt: Bool, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        
    }
    
    public static func deleteNote(id: Data, completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        deleteDoc(id: id, completion: completion)
    }
    
    //MARK: - Notebook
    public static func retrieveNotes(notebookID: Data, completion: @escaping (Result<[_Note], AiTmedError>) -> Void) {
        
    }
    
    public struct _Note {
        public var id: Data
        public var title: String
        public var content: Data
        public var ctime: Date = Date()
        public var mtime: Date = Date()
        public var isBroken = false
    }
    
    public struct _Notebook {
        
    }
}
