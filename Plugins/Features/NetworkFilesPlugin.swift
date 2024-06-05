//
//  NetworkFilesPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2023/10/3.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Alamofire
import Moya

/// 上传/下载文件资源插件
public final class NetworkFilesPlugin {
    // 默认下载保存地址
    public static let DownloadAssetDir: URL = {
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }()
    
    public enum OperateType {
        /// Upload pictures.
        case uploadImags([ImageType])
        /// Upload file.
        case uploadFile(URL)
        /// Upload multipart or form-data.
        case uploadMultipart([Moya.MultipartFormData])
        
        /// Download the file.
        case downloadAsset
        /// Download a destination.
        case downloadDestination(Moya.DownloadDestination)
    }
    
    /// 下载文件链接
    public private(set) var downloadAssetURL: URL?
    
    private(set) var task: Moya.Task?
    
    public let options: NetworkFilesPlugin.Options
    public let type: OperateType
    
    public init(type: OperateType, options: NetworkFilesPlugin.Options = .init()) {
        self.type = type
        self.options = options
    }
}

extension NetworkFilesPlugin {
    public struct Options {
        /// Choice of parameter encoding.
        public let encoding: Moya.ParameterEncoding
        /// Do you need default parameters with `BoomingSetup.baseParameters`.
        public let needBaseParameters: Bool
        
        public init(encoding: ParameterEncoding = JSONEncoding.default, needBaseParameters: Bool = false) {
            self.encoding = encoding
            self.needBaseParameters = needBaseParameters
        }
    }
}

extension NetworkFilesPlugin: PluginSubType {
    
    public var pluginName: String {
        return "Files"
    }
    
    public func configuration(_ request: HeadstreamRequest, target: TargetType) -> HeadstreamRequest {
        let baseURL: URL
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            baseURL = target.baseURL.appending(path: target.path)
        } else {
            baseURL = target.baseURL.appendingPathComponent(target.path)
        }
        if let api = target as? NetworkAPI {
            self.task = setupTask(parameters: api.parameters, baseURL: baseURL)
        } else if let multiTarget = target as? MultiTarget, let api = multiTarget.target as? NetworkAPI {
            self.task = setupTask(parameters: api.parameters, baseURL: baseURL)
        } else {
            self.task = setupTask(parameters: nil, baseURL: baseURL)
        }
        return request
    }
    
    public func outputResult(_ result: OutputResult, target: TargetType, onNext: @escaping OutputResultBlock) {
        switch result.result {
        case .success:
            if let downloadURL = downloadAssetURL {
                result.mappedResult = .success(downloadURL)
            }
        case .failure:
            break
        }
        onNext(result)
    }
}

extension NetworkFilesPlugin {
    
    private func parameters(_ parameters: APIParameters?) -> APIParameters {
        if options.needBaseParameters {
            var param = BoomingSetup.baseParameters
            if let dict = parameters {
                // Merge the dictionaries and take the second value
                param = param.merging(dict) { $1 }
            }
            return param
        }
        return parameters ?? [:]
    }
    
    private func setupTask(parameters: APIParameters?, baseURL: URL) -> Moya.Task? {
        let parameters = self.parameters(parameters)
        switch self.type {
        case .uploadImags(let images):
            let formDatas: [Moya.MultipartFormData] = images.compactMap {
                var imageData: Data?
                var fileName = "Booming-" + UUID().uuidString
                if let pngData = $0.pngData() {
                    imageData = pngData
                    fileName += ".png"
                } else if let jpgdata = $0.jpegData(compressionQuality: 1.0) {
                    imageData = jpgdata
                    fileName += ".jpeg"
                } else if #available(iOS 17.0, *), let heicData = $0.heicData() {
                    imageData = heicData
                    fileName += ".heic"
                }
                guard let imageData = imageData else {
                    return nil
                }
                return MultipartFormData(provider: .data(imageData), name: "file", fileName: fileName, mimeType: "image/png")
            }
            return .uploadMultipart(formDatas)
        case .uploadFile(let url):
            return Moya.Task.uploadFile(url)
        case .uploadMultipart(let datas):
            if parameters.isEmpty {
                return Moya.Task.uploadMultipart(datas)
            }
            return Moya.Task.uploadCompositeMultipart(datas, urlParameters: parameters)
        case .downloadAsset:
            let fileName = "Booming-" + UUID().uuidString
            var localLocation = Self.DownloadAssetDir.appendingPathComponent(fileName)
            localLocation = localLocation.appendingPathExtension(baseURL.pathExtension)
            self.downloadAssetURL = localLocation
            let destination: Moya.DownloadDestination = { _, _ in
                // `createIntermediateDirectories` will create directories in file path
                (localLocation, [.removePreviousFile, .createIntermediateDirectories])
            }
            //let destination = DownloadRequest.suggestedDownloadDestination(options: [.removePreviousFile])
            if parameters.isEmpty {
                return Moya.Task.downloadDestination(destination)
            }
            return Moya.Task.downloadParameters(parameters: parameters, encoding: options.encoding, destination: destination)
        case .downloadDestination(let destination):
            if parameters.isEmpty {
                return Moya.Task.downloadDestination(destination)
            }
            return Moya.Task.downloadParameters(parameters: parameters, encoding: options.encoding, destination: destination)
        }
    }
}
