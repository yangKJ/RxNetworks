//
//  Disk.swift
//  CacheX
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public struct Disk {
    /// A type that represents an byte.
    public typealias Byte = UInt
    
    /// A singleton shared disk cache.
    private static let disk: FileManager = FileManager()
    private static var createDirectory: Bool = false
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var named: String = "DiskCached"
    
    /// The longest time duration in second of the cache being stored in disk. default is an week.
    public var expiry: Expiry = Expiry.week
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb.
    public var maxCountLimit: Disk.Byte = 20 * 1024
    
    public init() { }
}

extension Disk: Cacheable {
    
    public static  var named: String {
        "CacheX_disk"
    }
    
    public func read(key: String) -> Data? {
        /// 过期清除缓存
        if isExpired(forKey: key), removeCache(key: key) {
            return nil
        }
        if let cachePath = diskCachePath(key: key),
           let data = try? Data(contentsOf: URL(fileURLWithPath: cachePath)) {
            return data
        }
        return nil
    }
    
    public func store(key: String, value: Data) {
        guard let cachePath = diskCachePath(key: key) else {
            return
        }
        createDirectoryFile()
        Disk.disk.createFile(atPath: cachePath, contents: value, attributes: nil)
    }
    
    @discardableResult public func removeCache(key: String) -> Bool {
        guard let filePath = diskCachePath(key: key) else {
            return false
        }
        do {
            try Disk.disk.removeItem(atPath: filePath)
            return true
        } catch { }
        return false
    }
    
    public func removedCached(completion: SuccessComplete) {
        guard let docPath = diskCacheDoc() else {
            completion(false)
            return
        }
        do {
            try Disk.disk.removeItem(atPath: docPath)
            try Disk.disk.createDirectory(atPath: docPath, withIntermediateDirectories: true, attributes: nil)
            completion(true)
        } catch {
            completion(false)
        }
    }
}

extension Disk {
    /// Get the disk cache size.
    public var totalCost: Disk.Byte {
        get {
            guard let docPath = diskCacheDoc(),
                  let contents = try? Disk.disk.contentsOfDirectory(atPath: docPath) else {
                return 0
            }
            var size: Disk.Byte = 0
            for pathComponent in contents {
                let filePath = NSString(string: docPath).appendingPathComponent(pathComponent)
                if let attributes = try? Disk.disk.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? Disk.Byte {
                    size += fileSize
                }
            }
            return size
        }
    }
    
    /// It's the file expired.
    public func isExpired(forKey key: String) -> Bool {
        guard let cachePath = diskCachePath(key: key),
              let attributes = try? Disk.disk.attributesOfItem(atPath: cachePath),
              let lastAccessData = attributes[.modificationDate] as? Date else {
            return false
        }
        return expiry.isExpired(lastAccessData)
    }
    
    /// Remove expired files from disk.
    /// - Parameter completion: Removed file URLs callback.
    public func removeExpiredURLsFromDisk(completion: ((_ expiredURLs: [URL]) -> Void)? = nil) {
        guard let tuple = getCachedFilesAndExpiredURLs() else {
            return
        }
        var expiredURLs = tuple.expiredURLs
        let cachedFiles = tuple.cachedFiles
        var diskCacheSize = tuple.diskCacheSize
        for fileURL in expiredURLs {
            try? Disk.disk.removeItem(at: fileURL)
        }
        typealias Sorted = Dictionary<URL, URLResourceValues>
        // Sort files by last modify date. We want to clean from the oldest files.
        func keysSortedByValue(dict: Sorted, isOrderedBefore: (Sorted.Value, Sorted.Value) -> Bool) -> [Sorted.Key] {
            return Array(dict).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
        }
        if maxCountLimit > 0 && diskCacheSize > maxCountLimit {
            let sortedFiles = keysSortedByValue(dict: cachedFiles) { value1, value2 -> Bool in
                if let date1 = value1.contentAccessDate, let date2 = value2.contentAccessDate {
                    return date1.compare(date2) == .orderedAscending
                }
                // Not valid date information. This should not happen. Just in case.
                return true
            }
            let targetSize = maxCountLimit / 2
            for fileURL in sortedFiles {
                if let _ = try? Disk.disk.removeItem(at: fileURL) {
                    expiredURLs.append(fileURL)
                    if let fileSize = cachedFiles[fileURL]?.totalFileAllocatedSize {
                        diskCacheSize -= Disk.Byte(fileSize)
                    }
                }
                if diskCacheSize < targetSize {
                    break
                }
            }
            completion?(expiredURLs)
        }
    }
    
    /// Get all the files under the disk.
    /// - Parameter ignoredFileName: Ignored file name.
    /// - Returns: Full path of file array.
    public func filePaths(ignoredFileName: String? = nil) -> [String] {
        guard let docPath = diskCacheDoc() else {
            return []
        }
        var paths = [String]()
        let enumerator = Disk.disk.enumerator(atPath: docPath)
        while let fileName = enumerator?.nextObject() as? String {
            if let tempFile = ignoredFileName, fileName.hasSuffix(tempFile) {
                continue
            }
            paths.append(docPath.appending("/\(fileName)"))
        }
        return paths
    }
}

extension Disk {
    /// Disk document path.
    private func diskCacheDoc() -> String? {
        let domains = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let prefix = domains.first else {
            return nil
        }
        return (prefix as NSString).appendingPathComponent(named)
    }
    
    /// The full path of the md5 encrypted file.
    /// - Parameter url: Link.
    /// - Returns: Cache path.
    private func diskCachePath(key: String) -> String? {
        guard let docPath = diskCacheDoc() else {
            return nil
        }
        return (docPath as NSString).appendingPathComponent(key)
    }
    
    private func createDirectoryFile() {
        if Disk.createDirectory {
            return
        }
        if let docPath = diskCacheDoc(), !Disk.disk.fileExists(atPath: docPath) {
            let url = URL(fileURLWithPath: docPath, isDirectory: true)
            do {
                try Disk.disk.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                Disk.createDirectory = true
            } catch { }
        }
    }
    
    /// Get disk cache files and file sizes and expired files.
    private func getCachedFilesAndExpiredURLs() -> (expiredURLs: [URL], cachedFiles: [URL: URLResourceValues], diskCacheSize: Disk.Byte)? {
        guard let docPath = diskCacheDoc() else {
            return nil
        }
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        guard let fileURLs = (try? Disk.disk.contentsOfDirectory(at: URL(fileURLWithPath: docPath),
                                                                 includingPropertiesForKeys: Array(resourceKeys),
                                                                 options: .skipsHiddenFiles)) else {
            return nil
        }
        var cachedFiles = [URL: URLResourceValues]()
        var expiredURLs = [URL]()
        var diskCacheSize: Disk.Byte = 0
        for fileURL in fileURLs {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }
                // If this file is expired, add it to URLsToDelete
                if let lastAccessData = resourceValues.contentAccessDate, expiry.isExpired(lastAccessData) {
                    expiredURLs.append(fileURL)
                    continue
                }
                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += Disk.Byte(fileSize)
                    cachedFiles[fileURL] = resourceValues
                }
            } catch { }
        }
        return (expiredURLs, cachedFiles, diskCacheSize)
    }
}
