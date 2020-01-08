//
//  Data.swift
//  AiTmedSDK
//
//  Created by Yi Tong on 1/2/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import Foundation
import zlib

private let GZIP_STREAM_SIZE: Int32 = Int32(MemoryLayout<z_stream>.size)
private let GZIP_BUF_LENGTH:Int = 512

extension Data {
    var isEmbedSatisfied: Bool {
        return count < 256 * 1024
    }
    
    var isZipSatisfied: Bool {
        if let zipped = zip(), zipped.count < count {
            return true
        } else {
            return false
        }
    }
    
    func isZipped() -> Bool {
        return self.starts(with: [0x1f,0x8b])
    }
    
    func zip() -> Data? {
        guard self.count > 0 else {
            return self
        }
        
        var stream = z_stream()
        stream.avail_in = uInt(self.count)
        stream.total_out = 0
        
        self.withUnsafeBytes { (bytes:UnsafePointer<Bytef>) in
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating:bytes)
        }
        
        var status = deflateInit2_(&stream,Z_DEFAULT_COMPRESSION, Z_DEFLATED, MAX_WBITS + 16, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, GZIP_STREAM_SIZE)
        
        if  status != Z_OK {
            return  nil
        }
        
        var compressedData = Data()
        
        while stream.avail_out == 0 {
            
            if Int(stream.total_out) >= compressedData.count {
                compressedData.count += GZIP_BUF_LENGTH
            }
            
            stream.avail_out = uInt(GZIP_BUF_LENGTH)
            
            compressedData.withUnsafeMutableBytes { (bytes:UnsafeMutablePointer<Bytef>) -> Void in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            
            status = deflate(&stream, Z_FINISH)
            
            if status != Z_OK && status != Z_STREAM_END {
                return nil
            }
        }
        
        guard deflateEnd(&stream) == Z_OK else {
            return nil
        }
        
        compressedData.count = Int(stream.total_out)
        return compressedData
    }
    
    func unzip() -> Data? {
        guard self.count > 0  else {
            return nil
        }
        
        guard self.isZipped() else {
            return self
        }
        
        var  stream = z_stream()
        
        self.withUnsafeBytes { (bytes:UnsafePointer<Bytef>) in
            stream.next_in =  UnsafeMutablePointer<Bytef>(mutating: bytes)
        }
        
        stream.avail_in = uInt(self.count)
        stream.total_out = 0
        
        
        var status: Int32 = inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION,GZIP_STREAM_SIZE)
        
        guard status == Z_OK else {
            return nil
        }
        
        var decompressed = Data(capacity: self.count * 2)
        while stream.avail_out == 0 {
            
            stream.avail_out = uInt(GZIP_BUF_LENGTH)
            decompressed.count += GZIP_BUF_LENGTH
            
            decompressed.withUnsafeMutableBytes { (bytes:UnsafeMutablePointer<Bytef>)in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            
            status = inflate(&stream, Z_SYNC_FLUSH)
            
            if status != Z_OK && status != Z_STREAM_END {
                break
            }
        }
        
        if inflateEnd(&stream) != Z_OK {
            return nil
        }
        
        decompressed.count = Int(stream.total_out)
        return decompressed
    }
}
