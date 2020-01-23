//
//  DocumentType.swift
//  AiTmedSDK1
//
//  Created by Yi Tong on 1/22/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation

struct DocumentType: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt32
    var value: UInt32
    
    init(integerLiteral value: UInt32) {
        self.value = value
    }
    
    init(value: UInt32) {
        self.value = value
    }
    
    private let isOnServerPosition = 0
    private let isZippedPosition = 1
    private let isBinaryPosition = 2
    private let isEncryptPosition = 3
    private let isExtraKeyNeededPosition = 4
    private let isEditablePosition = 5
    private let applicationDataTypeStartPosition = 17
    private let applicationDataTypeEndPosition = 26
    private let mediaTypeKindStartPosition = 27
    private let mediaTypeKindEndPosition = 31
    
    var isOnServer: Bool {
        get {
            return value.isSet(isOnServerPosition)
        }
        
        set {
            newValue ? value.set(isOnServerPosition) : value.unset(isOnServerPosition)
        }
    }
    
    var isZipped: Bool {
        get {
            return value.isSet(isZippedPosition)
        }
        
        set {
            newValue ? value.set(isZippedPosition) : value.unset(isZippedPosition)
        }
    }
    
    var isBinary: Bool {
        get {
            return value.isSet(isBinaryPosition)
        }
        
        set {
            newValue ? value.set(isBinaryPosition) : value.unset(isBinaryPosition)
        }
    }
    
    var isEncrypt: Bool {
        get {
            return value.isSet(isEncryptPosition)
        }
        
        set {
            newValue ? value.set(isEncryptPosition) : value.unset(isEncryptPosition)
        }
    }
    
    var isExtraKeyNeeded: Bool {
        get {
            return value.isSet(isExtraKeyNeededPosition)
        }
        
        set {
            newValue ? value.set(isExtraKeyNeededPosition) : value.unset(isExtraKeyNeededPosition)
        }
    }
    
    var isEditable: Bool {
        get {
            return value.isSet(isEditablePosition)
        }
        
        set {
            newValue ? value.set(isEditablePosition) : value.unset(isEditablePosition)
        }
    }
    
    var applicationDataType: ApplicationDataType {
        get {
            return ApplicationDataType(rawValue: value.value(from: applicationDataTypeStartPosition, through: applicationDataTypeEndPosition)) ?? .data
        }
        
        set {
            value.set(from: applicationDataTypeStartPosition, through: applicationDataTypeEndPosition, with: newValue.rawValue)
        }
    }
    
    var mediaTypeKind: MediaTypeKind {
        get {
            return MediaTypeKind(rawValue: value.value(from: mediaTypeKindStartPosition, through: mediaTypeKindEndPosition)) ?? .other
        }
        
        set {
            value.set(from: mediaTypeKindStartPosition, through: mediaTypeKindEndPosition, with: newValue.rawValue)
        }
    }
}

public enum ApplicationDataType: UInt32 {
    case data
    case profile
    case vital
}

public enum MediaType: String {
    case plain = "text/plain"
    case html = "text/html"
    case json = "application/json"
    case other
    
    var kind: MediaTypeKind {
        if rawValue.hasPrefix("text") {
            return .text
        } else if rawValue.hasPrefix("application") {
            return .application
        } else {
            return .other
        }
    }
}

public enum MediaTypeKind: UInt32 {
    case other = 0
    case application
    case audio
    case font
    case image
    case message
    case model
    case multipart
    case text
    case video
}
