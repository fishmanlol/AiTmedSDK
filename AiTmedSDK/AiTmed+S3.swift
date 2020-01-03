//
//  AiTmed+S3.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 1/2/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import Alamofire

extension AiTmed {
    //MARK: - Download
//    public static func download(from url: URL, completion: @escaping (Swift.Result<Data, AiTmedError>) -> Void) {
//        Alamofire.download(url).responseData { (response) in
//            switch response.result {
//            case .failure(let error):
//                completion(.)
//            }
//        }
//        switch result {
//        case .failure(let error):
//            document.isBroken = true
//        case .success(let data):
//            document.content =
//        }
//    }
//
    //MARK: - Upload
    public static func upload(data: Data, to url: URL, completion: @escaping (Swift.Result<Void, AiTmedError>) -> Void) {
//        Alamofire.upload(data, to: url, method: .get, headers: nil)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completion(.success(()))
        }
    }
}
