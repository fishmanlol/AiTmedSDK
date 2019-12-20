//
//  Notebook.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

extension AiTmed.Prynote {
    public struct Notebook {
        public var id: Data
        public var title: String = ""
        public var isEncrypt = true
    }
    
    public struct Note: File {
        public var type: MimeType
        public var id: Data
        public var title: String?
        public var content: Data?
        public var uploadUrl: String?
        public var downloadUrl: String?
        public var isEncrypt = true
    }
}
