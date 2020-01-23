//
//  File.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

//import Foundation
//import UIKit
//

//Different from Edge and Vertex, Doc is more complicate. For example, the content of Doc may store on server or S3, the content may be zipped or not, the content may be encrypted or not. So we add one layer Document above Doc
//immature document don't have id and did not exchange with backend
struct Document {
    let id: Data
    let folderID: Data
    let title: String
    let mediaType: MediaType
    let ctime: Date
    let mtime: Date
    var content: Data
    var isBroken = false
    //Reference - https://demo.codimd.org/ZV_6kJ4TQu2ExkraJgWTdw, 1 is true, 0 is false
    let type: DocumentType
    
    init(id: Data, folderID: Data, title: String, content: Data, isBroken: Bool, mediaType: MediaType, type: DocumentType, mtime: Int64, ctime: Int64) {
        self.id = id
        self.folderID = folderID
        self.title = title
        self.content = content
        self.isBroken = isBroken
        self.type = type
        self.mediaType = mediaType
        self.mtime = Date(timeIntervalSince1970: TimeInterval(mtime))
        self.ctime = Date(timeIntervalSince1970: TimeInterval(ctime))
    }
}


