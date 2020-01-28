////
////  Data.swift
////  AiTmedSDK
////
////  Created by Yi Tong on 1/2/20.
////  Copyright © 2020 Yi Tong. All rights reserved.
////
//
//import Foundation
//import zlib
//
//private let GZIP_STREAM_SIZE: Int32 = Int32(MemoryLayout<z_stream>.size)
//private let GZIP_BUF_LENGTH:Int = 512
//
//private struct DataSize {
//    
//    static let chunk = 1 << 14
//    static let stream = MemoryLayout<z_stream>.size
//    
//    private init() { }
//}
//
//extension Data {
//    var isEmbedSatisfied: Bool {
//        return count < 256 * 1024
//    }
//    
//    var isZipSatisfied: Bool {
//        if zip().count < count {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func isZipped() -> Bool {
//        return self.starts(with: [0x1f,0x8b])
//    }
//    
//    func zip() -> Data {
//        guard !self.isEmpty else {
//            return Data()
//        }
//        
//        var stream = z_stream()
//        var status: Int32
//        
//        status = deflateInit2_(&stream, level.rawValue, Z_DEFLATED, MAX_WBITS + 16, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, GZIP_STREAM_SIZE)
//        
//        guard status == Z_OK else {
//            // deflateInit2 returns:
//            // Z_VERSION_ERROR  The zlib library version is incompatible with the version assumed by the caller.
//            // Z_MEM_ERROR      There was not enough memory.
//            // Z_STREAM_ERROR   A parameter is invalid.
//            
//            return Data()
//        }
//        
//        var data = Data(capacity: DataSize.chunk)
//        repeat {
//            if Int(stream.total_out) >= data.count {
//                data.count += DataSize.chunk
//            }
//            
//            let inputCount = self.count
//            let outputCount = data.count
//            
//            self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
//                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!).advanced(by: Int(stream.total_in))
//                stream.avail_in = uint(inputCount) - uInt(stream.total_in)
//                
//                data.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
//                    stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!.advanced(by: Int(stream.total_out))
//                    stream.avail_out = uInt(outputCount) - uInt(stream.total_out)
//                    
//                    status = deflate(&stream, Z_FINISH)
//                    
//                    stream.next_out = nil
//                }
//                
//                stream.next_in = nil
//            }
//            
//        } while stream.avail_out == 0
//        
//        guard deflateEnd(&stream) == Z_OK, status == Z_STREAM_END else {
//            return Data()
//        }
//        
//        data.count = Int(stream.total_out)
//        
//        return data
//    }
//    
//    func unzip() -> Data {
//        guard !self.isEmpty else {
//            return Data()
//        }
//        
//        var stream = z_stream()
//        var status: Int32
//        
//        status = inflateInit2_(&stream, MAX_WBITS + 32, ZLIB_VERSION, Int32(DataSize.stream))
//        
//        guard status == Z_OK else {
//            // inflateInit2 returns:
//            // Z_VERSION_ERROR   The zlib library version is incompatible with the version assumed by the caller.
//            // Z_MEM_ERROR       There was not enough memory.
//            // Z_STREAM_ERROR    A parameters are invalid.
//            
//            throw GzipError(code: status, msg: stream.msg)
//        }
//        
//        var data = Data(capacity: self.count * 2)
//        repeat {
//            if Int(stream.total_out) >= data.count {
//                data.count += self.count / 2
//            }
//            
//            let inputCount = self.count
//            let outputCount = data.count
//            
//            self.withUnsafeBytes { (inputPointer: UnsafeRawBufferPointer) in
//                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: inputPointer.bindMemory(to: Bytef.self).baseAddress!).advanced(by: Int(stream.total_in))
//                stream.avail_in = uint(inputCount) - uInt(stream.total_in)
//                
//                data.withUnsafeMutableBytes { (outputPointer: UnsafeMutableRawBufferPointer) in
//                    stream.next_out = outputPointer.bindMemory(to: Bytef.self).baseAddress!.advanced(by: Int(stream.total_out))
//                    stream.avail_out = uInt(outputCount) - uInt(stream.total_out)
//                    
//                    status = inflate(&stream, Z_SYNC_FLUSH)
//                    
//                    stream.next_out = nil
//                }
//                
//                stream.next_in = nil
//            }
//            
//        } while status == Z_OK
//        
//        guard inflateEnd(&stream) == Z_OK, status == Z_STREAM_END else {
//            // inflate returns:
//            // Z_DATA_ERROR   The input data was corrupted (input stream not conforming to the zlib format or incorrect check value).
//            // Z_STREAM_ERROR The stream structure was inconsistent (for example if next_in or next_out was NULL).
//            // Z_MEM_ERROR    There was not enough memory.
//            // Z_BUF_ERROR    No progress is possible or there was not enough room in the output buffer when Z_FINISH is used.
//            
//            return Data()
//        }
//        
//        data.count = Int(stream.total_out)
//        
//        return data
//    }
//    
//    func zip1() -> Data {
//        guard self.count > 0 else {
//            return self
//        }
//        
//        var stream = z_stream()
//        stream.avail_in = uInt(self.count)
//        stream.total_out = 0
//        
//        self.withUnsafeBytes { (bytes:UnsafePointer<Bytef>) in
//            stream.next_in = UnsafeMutablePointer<Bytef>(mutating:bytes)
//        }
//        
//        var status = deflateInit2_(&stream,Z_DEFAULT_COMPRESSION, Z_DEFLATED, MAX_WBITS + 16, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, GZIP_STREAM_SIZE)
//        
//        if  status != Z_OK {
//            return Data()
//        }
//        
//        var compressedData = Data()
//        
//        while stream.avail_out == 0 {
//            
//            if Int(stream.total_out) >= compressedData.count {
//                compressedData.count += GZIP_BUF_LENGTH
//            }
//            
//            stream.avail_out = uInt(GZIP_BUF_LENGTH)
//            
//            compressedData.withUnsafeMutableBytes { (bytes:UnsafeMutablePointer<Bytef>) -> Void in
//                stream.next_out = bytes.advanced(by: Int(stream.total_out))
//            }
//            
//            status = deflate(&stream, Z_FINISH)
//            
//            if status != Z_OK && status != Z_STREAM_END {
//                return Data()
//            }
//        }
//        
//        guard deflateEnd(&stream) == Z_OK else {
//            return Data()
//        }
//        
//        compressedData.count = Int(stream.total_out)
//        return compressedData
//    }
//    
//    func unzip1() -> Data? {
//        guard self.count > 0  else {
//            return nil
//        }
//        
//        guard self.isZipped() else {
//            return self
//        }
//        
//        var  stream = z_stream()
//        
//        self.withUnsafeBytes { (bytes:UnsafePointer<Bytef>) in
//            stream.next_in =  UnsafeMutablePointer<Bytef>(mutating: bytes)
//        }
//        
//        stream.avail_in = uInt(self.count)
//        stream.total_out = 0
//        
//        
//        var status: Int32 = inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION,GZIP_STREAM_SIZE)
//        
//        guard status == Z_OK else {
//            return nil
//        }
//        
//        var decompressed = Data(capacity: self.count * 2)
//        while stream.avail_out == 0 {
//            
//            stream.avail_out = uInt(GZIP_BUF_LENGTH)
//            decompressed.count += GZIP_BUF_LENGTH
//            
//            decompressed.withUnsafeMutableBytes { (bytes:UnsafeMutablePointer<Bytef>)in
//                stream.next_out = bytes.advanced(by: Int(stream.total_out))
//            }
//            
//            status = inflate(&stream, Z_SYNC_FLUSH)
//            
//            if status != Z_OK && status != Z_STREAM_END {
//                break
//            }
//        }
//        
//        if inflateEnd(&stream) != Z_OK {
//            return nil
//        }
//        
//        decompressed.count = Int(stream.total_out)
//        return decompressed
//    }//[31, 139, 8, 0, 0, 0, 0, 0, 0, 19, 11, 201, 200, 44, 86, 0, 162, 196, 146, 212, 226, 146, 148, 226, 226, 148, 52, 0, 131, 223, 164, 175, 18, 0, 0, 0]
//    
//}
