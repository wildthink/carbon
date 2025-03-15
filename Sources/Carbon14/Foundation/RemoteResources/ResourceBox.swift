//
//  ResourceBox.swift
//  Carbon14
//
//  Created by Jason Jobe on 12/20/24.
//

import Foundation

public actor DataLoader {
    private var status: LoaderStatus
    public let localCacheFile: URL
    
    public init(url: URL, cache: URL) {
        self.status = .ready(URLRequest(url: url))
        self.localCacheFile = cache
    }
    
    public init(request: URLRequest, cache: URL) {
        self.status = .ready(request)
        self.localCacheFile = cache
    }
    
    public func fetch() async throws -> Data {
        var urlRequest: URLRequest
        
        switch status {
        case .ready(let req):
            urlRequest = req
        case .fetched(let data):
            return data
        case .inProgress(let task):
            return try await task.value
        }
        
        if let data = try self.dataFromFileSystem(for: urlRequest) {
            status = .fetched(data)
            return data
        }
        
        let task: Task<Data, Error> = Task {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            try self.persist(data, for: urlRequest)
            return data
        }
        
        status = .inProgress(task)
        let data = try await task.value
        status = .fetched(data)
        return data
    }
    
    
    private func persist(_ data: Data, for urlRequest: URLRequest) throws {
        guard localCacheFile.isFileURL else {
            throw AnyError()
        }
        try FileManager.default
            .createDirectory(at: localCacheFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: localCacheFile)
    }
    
    private enum LoaderStatus {
        case ready(URLRequest)
        case inProgress(Task<Data, Error>)
        case fetched(Data)
    }
    
    private func dataFromFileSystem(for urlRequest: URLRequest) throws -> Data? {
        guard FileManager.default.fileExists(at: localCacheFile)
        else { return nil }
        return try Data(contentsOf: localCacheFile)
    }
}
