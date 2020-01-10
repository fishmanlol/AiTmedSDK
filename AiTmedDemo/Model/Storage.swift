//
//  Storeage.swift
//  AiTmedDemo
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import AiTmedSDK1

class Storage {
    static var `default` = Storage()
    var notebooks: [Notebook] = []
    
    private init() {}
    
    func retrieveNotebooks(completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        AiTmed.retrieveNotebooks { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    func addNotebook(title: String, isEncrypt: Bool, completion: @escaping (Result<Notebook, PrynoteError>) -> Void) {
        AiTmed.addNotebook(title: title, isEncrypt: isEncrypt) { [weak self] (result) in
            guard let weakSelf = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let _notebook):
                let notebook = Notebook(_notebook)
                weakSelf.notebooks.append(notebook)
                completion(.success(notebook))
            }
        }
    }
}
