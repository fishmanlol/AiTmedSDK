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
    let rawContent: Data
    let mime: MediaType
    let isEncrypt: Bool
    let folderID: Data
    let isBinary: Bool
    let isExtraKeyNeeded: Bool
    let isInvitable: Bool
    let isEditable: Bool
    let isViewable: Bool
    
    init(title: String, rawContent: Data, mime: MediaType, isEncrypt: Bool, folderID: Data, isBinary: Bool, isExtraKeyNeeded: Bool = false, isInvitable: Bool = true, isEditable: Bool = true, isViewable: Bool = true) {
        self.title = title
        self.rawContent = rawContent
        self.mime = mime
        self.isEncrypt = isEncrypt
        self.folderID = folderID
        self.isBinary = isBinary
        self.isExtraKeyNeeded = isExtraKeyNeeded
        self.isInvitable = isInvitable
        self.isEditable = isEditable
        self.isViewable = isViewable
    }
}

class UpdateDocumentArgs: CreateDocumentArgs {
    let id: Data

    init(id: Data, title: String, rawContent: Data, mime: MediaType, isEncrypt: Bool, folderID: Data, isBinary: Bool, isExtraKeyNeeded: Bool = false, isInvitable: Bool = true, isEditable: Bool = true, isViewable: Bool = true) {
        self.id = id
        super.init(title: title, rawContent: rawContent, mime: mime, isEncrypt: isEncrypt, folderID: folderID, isBinary: isBinary, isExtraKeyNeeded: isExtraKeyNeeded, isInvitable: isInvitable, isEditable: isEditable, isViewable: isViewable)
    }
}
