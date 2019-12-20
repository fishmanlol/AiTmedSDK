//
//  File.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 12/19/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

public protocol File {
    var title: String? { get set }
    var content: Data? { get set }
    var isEncrypt: Bool { get set }
    var uploadUrl: String? { get set }
    var downloadUrl: String? { get set }
    var type: MimeType { get set }
}

public enum MimeType: String {
    case html = "text/html"
    case markdown = "text/markdown"
    case plain = "text/plain"
    case png
    case jpeg
    case json
}
