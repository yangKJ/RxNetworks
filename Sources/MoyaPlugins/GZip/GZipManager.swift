//
//  GZipManager.swift
//  RxNetworks
//
//  Created by Condy on 2021/10/8.
//

import Foundation
import zlib

extension Data {
    /// 判断是否为`GZip`压缩数据
    public var isGZipCompressed: Bool {
        return self.starts(with: [0x1f, 0x8b])
    }
}

public struct GZipManager {
    // 解压缩流大小
    static let GZIP_STREAM_SIZE: Int32 = Int32(MemoryLayout<z_stream>.size)
    // 解压缩缓冲区大小
    static let GZIP_BUF_LENGTH: Int = 512
}

extension GZipManager {
    
    public static func gzipCompress(_ data: Data) -> Data {
        guard data.count > 0 else { return data }
        var stream = z_stream()
        stream.avail_in = uInt(data.count)
        stream.total_out = 0
        data.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: bytes)
        }
        var status = deflateInit2_(&stream,
                                   Z_DEFAULT_COMPRESSION,
                                   Z_DEFLATED,
                                   MAX_WBITS + 16,
                                   MAX_MEM_LEVEL,
                                   Z_DEFAULT_STRATEGY,
                                   ZLIB_VERSION,
                                   GZIP_STREAM_SIZE)
        if  status != Z_OK {
            return Data()
        }
        
        var compressedData = Data()
        while stream.avail_out == 0 {
            if Int(stream.total_out) >= compressedData.count {
                compressedData.count += GZIP_BUF_LENGTH
            }
            stream.avail_out = uInt(GZIP_BUF_LENGTH)
            compressedData.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) -> Void in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            status = deflate(&stream, Z_FINISH)
            if status != Z_OK && status != Z_STREAM_END {
                return Data()
            }
        }
        guard deflateEnd(&stream) == Z_OK else {
            return Data()
        }
        compressedData.count = Int(stream.total_out)
        return compressedData
    }
}

extension GZipManager {
    
    public static func gzipUncompress(_ data: Data) -> Data {
        guard data.count > 0 else {
            return Data()
        }
        guard data.isGZipCompressed else {
            return data
        }
        var stream = z_stream()
        data.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            stream.next_in =  UnsafeMutablePointer<Bytef>(mutating: bytes)
        }
        stream.avail_in = uInt(data.count)
        stream.total_out = 0
        var status: Int32 = inflateInit2_(&stream, MAX_WBITS + 16, ZLIB_VERSION, GZIP_STREAM_SIZE)
        guard status == Z_OK else {
            return Data()
        }
        var decompressed = Data(capacity: data.count * 2)
        while stream.avail_out == 0 {
            stream.avail_out = uInt(GZIP_BUF_LENGTH)
            decompressed.count += GZIP_BUF_LENGTH
            decompressed.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                stream.next_out = bytes.advanced(by: Int(stream.total_out))
            }
            status = inflate(&stream, Z_SYNC_FLUSH)
            if status != Z_OK && status != Z_STREAM_END {
                break
            }
        }
        if inflateEnd(&stream) != Z_OK {
            return Data()
        }
        decompressed.count = Int(stream.total_out)
        return decompressed
    }
}
