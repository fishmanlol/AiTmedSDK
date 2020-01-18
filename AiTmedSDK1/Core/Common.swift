//
//  Common.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //transform RetrieveArgs and DeleteArgs
//    func transform(args: RetrieveArgs, completion: (Result<RetrieveArgs, AiTmedError>) -> Void) {
//        if let error = checkStatus() {
//            completion(.failure(error))
//            return
//        }
//        completion(.success(args))
//    }
//    
//    func transform(args: DeleteArgs, completion: (Result<DeleteArgs, AiTmedError>) -> Void) {
//        if let error = checkStatus() {
//            completion(.failure(error))
//            return
//        }
//        completion(.success(args))
//    }
}

//MARK: - Retrieve
class RetrieveArgs {
    let ids: [Data]//if empty, all objects in that type will be retrieved
    var type: Int32?
    var maxCount: Int32?//if nil, no limitation on maxCount
    
    init(ids: [Data] = [], type: Int32? = nil, maxCount: Int32? = nil) {
        self.ids = ids
        self.type = type
        self.maxCount = maxCount
    }
}

class RetrieveSingleArgs: RetrieveArgs {
    init(id: Data, type: Int32? = nil) {
        super.init(ids: [id], type: type, maxCount: nil)
    }
}

//MARK: - Delete
struct DeleteArgs {
    let id: Data
}
