//
//  Disk.swift
//  RxNetworks
//
//  Created by Condy on 2023/3/23.
//

import Foundation

public struct Disk {
    /// A singleton shared disk cache.
    static let disk: FileManager = FileManager()
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var named: String = "DiskCached"
    
    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week ``60 * 60 * 24 * 7 seconds``.
    public var expiry: Expiry = .seconds(60 * 60 * 24 * 7)
    
    /// The maximum total cost that the cache can hold before it starts evicting objects. default 20kb.
    public var maxCostLimit: UInt = 20 * 1024
}

extension Disk {
    /// Get the disk cache size.
    public var totalCost: UInt64 {
        get {
            guard let docPath = diskCacheDoc(),
                  let contents = try? Disk.disk.contentsOfDirectory(atPath: docPath) else {
                return 0
            }
            var size: UInt64 = 0
            for pathComponent in contents {
                let filePath = NSString(string: docPath).appendingPathComponent(pathComponent)
                if let attributes = try? Disk.disk.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? UInt64 {
                    size += fileSize
                }
            }
            return size
        }
    }
    
    public func diskCacheData(key: String) -> Data? {
        if let cachePath = diskCachePath(key: key),
           let data = try? Data(contentsOf: URL(fileURLWithPath: cachePath)) {
            return data
        }
        return nil
    }
    
    public func store2Disk(with data: Data, key: String) {
        if let docPath = diskCacheDoc(), !Disk.disk.fileExists(atPath: docPath) {
            let url = URL(fileURLWithPath: docPath, isDirectory: true)
            try? Disk.disk.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        guard let cachePath = diskCachePath(key: key) else {
            return
        }
        Disk.disk.createFile(atPath: cachePath, contents: data, attributes: nil)
    }
    
    /// Clear the disk cache.
    /// - Parameter completion: Complete the callback.
    public func removeAllDiskCache(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        guard let docPath = diskCacheDoc() else {
            completion?(false)
            return
        }
        do {
            try Disk.disk.removeItem(atPath: docPath)
            try Disk.disk.createDirectory(atPath: docPath, withIntermediateDirectories: true, attributes: nil)
            completion?(true)
        } catch {
            completion?(false)
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
    
    /// Clear the cache according to key value.
    public func removeObjectCache(_ key: String) -> Bool {
        guard let filePath = diskCachePath(key: key) else {
            return false
        }
        do {
            try Disk.disk.removeItem(atPath: filePath)
            return true
        } catch { }
        return false
    }
    
    /// Remove expired files from disk.
    /// - Parameter completion: Removed file URLs callback.
    public func removeExpiredURLsFromDisk(completion: ((_ expiredURLs: [URL]) -> Void)? = nil) {
        if case .never = expiry {
            return
        }
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
        if maxCostLimit > 0 && diskCacheSize > maxCostLimit {
            let sortedFiles = keysSortedByValue(dict: cachedFiles) { value1, value2 -> Bool in
                if let date1 = value1.contentAccessDate, let date2 = value2.contentAccessDate {
                    return date1.compare(date2) == .orderedAscending
                }
                // Not valid date information. This should not happen. Just in case.
                return true
            }
            let targetSize = maxCostLimit / 2
            for fileURL in sortedFiles {
                if let _ = try? Disk.disk.removeItem(at: fileURL) {
                    expiredURLs.append(fileURL)
                    if let fileSize = cachedFiles[fileURL]?.totalFileAllocatedSize {
                        diskCacheSize -= UInt(fileSize)
                    }
                }
                if diskCacheSize < targetSize {
                    break
                }
            }
            completion?(expiredURLs)
        }
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
    
    /// Get disk cache files and file sizes and expired files.
    private func getCachedFilesAndExpiredURLs() -> (expiredURLs: [URL], cachedFiles: [URL: URLResourceValues], diskCacheSize: UInt)? {
        guard let docPath = diskCacheDoc() else {
            return nil
        }
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        guard let fileUrls = (try? Disk.disk.contentsOfDirectory(at: URL(fileURLWithPath: docPath),
                                                                 includingPropertiesForKeys: Array(resourceKeys),
                                                                 options: .skipsHiddenFiles)) else {
            return nil
        }
        var cachedFiles = [URL: URLResourceValues]()
        var expiredURLs = [URL]()
        var diskCacheSize: UInt = 0
        for fileUrl in fileUrls {
            do {
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }
                // If this file is expired, add it to URLsToDelete
                if let lastAccessData = resourceValues.contentAccessDate, expiry.isExpired(lastAccessData) {
                    expiredURLs.append(fileUrl)
                    continue
                }
                if let fileSize = resourceValues.totalFileAllocatedSize {
                    diskCacheSize += UInt(fileSize)
                    cachedFiles[fileUrl] = resourceValues
                }
            } catch { }
        }
        return (expiredURLs, cachedFiles, diskCacheSize)
    }
}
