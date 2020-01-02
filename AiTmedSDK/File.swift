//
//  File.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

public enum MimeType: String {
    case html = "text/html"
    case markdown = "text/markdown"
    case plain = "text/plain"
    case png
    case jpeg
    case json
}

public struct File {
    var title: String?
    var content: Data?
    var isEncrypt: Bool = false
    var uploadUrl: String?
    var downloadUrl: String?
    var type: MimeType
}
