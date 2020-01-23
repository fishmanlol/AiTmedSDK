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
    let applicationDataType: ApplicationDataType
    let mediaType: MediaType
    let folderID: Data
    let isOnServer: Bool
    let isZipped: Bool
    let isEncrypt: Bool
    let isBinary: Bool
    let isExtraKeyNeeded: Bool
    let isEditable: Bool
    
    init(title: String, rawContent: Data, applicationDataType: ApplicationDataType, mediaType: MediaType, isEncrypt: Bool, folderID: Data, isOnServer: Bool, isZipped: Bool, isBinary: Bool = false, isExtraKeyNeeded: Bool = false, isEditable: Bool = true) {
        self.title = title
        self.rawContent = rawContent
        self.applicationDataType = applicationDataType
        self.mediaType = mediaType
        self.folderID = folderID
        self.isOnServer = isOnServer
        self.isZipped = isZipped
        self.isEncrypt = isEncrypt
        self.isBinary = isBinary
        self.isExtraKeyNeeded = isExtraKeyNeeded
        self.isEditable = isEditable
    }
}

class UpdateDocumentArgs: CreateDocumentArgs {
    let id: Data

    init(id: Data, title: String, rawContent: Data, applicationDataType: ApplicationDataType, mediaType: MediaType, isEncrypt: Bool, folderID: Data, isOnServer: Bool, isZipped: Bool, isBinary: Bool = false, isExtraKeyNeeded: Bool = false, isEditable: Bool = true) {
        self.id = id
        super.init(title: title, rawContent: rawContent, applicationDataType: applicationDataType, mediaType: mediaType, isEncrypt: isEncrypt, folderID: folderID, isOnServer: isOnServer, isZipped: isZipped)
    }
}
