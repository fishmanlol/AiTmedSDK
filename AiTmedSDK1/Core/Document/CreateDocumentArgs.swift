//
//  CreateDocumentArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/16/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

class CreateDocumentArgs {
    let title: String
    let content: Data
    let isEncrypt: Bool
    let folderID: Data
    let mime: MimeType
    let type: Int32
    
    var isOnS3: Bool {
        return type == AiTmedType.s3Data
    }
    
    var isZipSatisfied: Bool {
        return content.isZipSatisfied
    }
    
    init(folderID: Data, isEncrypt: Bool, title: String, content: Data = Data(), mime: MimeType = .data) {
        self.title = title
        self.content = content
        self.isEncrypt = isEncrypt
        self.folderID = folderID
        self.mime = mime
        
        if content.isEmbedSatisfied {
            type = AiTmedType.embedData
        } else {
            type = AiTmedType.s3Data
        }
    }
}

class UpdateDocumentArgs: CreateDocumentArgs {
    let id: Data
    
    init(id: Data, folderID: Data, isEncrypt: Bool, title: String, content: Data = Data(), mime: MimeType = .data) {
        self.id = id
        super.init(folderID: folderID, isEncrypt: isEncrypt, title: title, content: content, mime: mime)
    }
}
