//
//  Helper.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

extension AiTmed {
    //MARK: - Helper
    static func xeskPairInEdge(_ id: Data, completion: @escaping (Result<(Key, Key)?, AiTmedError>) -> Void) {
        AiTmed.retrieveEdges(args: RetrieveEdgesArgs(ids: [id], maxCount: nil)) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let edges):
                if let edge = edges.first, edge.besak.count > 0, edge.eesak.count > 0  {
                    completion(.success((Key(edge.besak), Key(edge.eesak))))
                } else {
                    completion(.success(nil))
                }
            }
        }
    }
}
