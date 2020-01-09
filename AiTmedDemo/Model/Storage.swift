//
//  Storeage.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK1

struct Storage {
    static var `default` = Storage()
    var notebooks: [Notebook] = []
    
    private init() {}
    
    func retrieveNotebooks(completion: @escaping (Result<Void, AiTmedError>) -> Void) {
        AiTmed.retrieveNotebooks { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
        AiTmed.addNotebook(title: title, isEncrypt: isEncrypt) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                fatalError()
            }
        }
    }
}
