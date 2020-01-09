//
//  CreateDocumentArgs.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/8/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

public class CreateDocumentArgs {
    var title: String
    var content: Data
    var isEncrypt: Bool
    var folderID: Data
    var mime: MimeType
    var type: Int32
    
    var isOnS3: Bool {
        return type == AiTmedType.s3Data
    }
    
    var isZipSatisfied: Bool {
        return content.isZipSatisfied
    }
    
    public init(title: String = "", content: Data = Data(), isEncrypt: Bool = false, mime: MimeType = .data, folderID: Data) {
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
