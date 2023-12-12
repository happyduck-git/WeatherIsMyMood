//
//  FirestoreManager.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 12/11/23.
//

import Foundation
import UIKit.UIImage
import FirebaseStorage

actor FirestoreManager {
    static let shared = FirestoreManager()
    
    private init() {}
    
    private let storageRef = Storage.storage().reference()
    private let cacheManager = StorageCacheManager.shared
    
    typealias PaginatedResult = (data: [Data], pageToken: String?)
}

extension FirestoreManager {
    func fetchWeatherIcons(_ condition: String) async throws -> [Data] {
        let list = try await self.storageRef
            .child("icon/weather/\(condition)")
            .listAll()
        
        return try await convertListResultToData(list)
    }
    
    func fetchOtherIcons(maxResults: Int64,
                         pageToken: String? = nil) async throws -> PaginatedResult {
            
        let storageRef = self.storageRef
            .child("icon/others")
           
        var list: StorageListResult?
        
        if let pageToken {
            list = try await storageRef.list(maxResults: maxResults, pageToken: pageToken)
            
        } else {
            list = try await storageRef.list(maxResults: maxResults)
        }
        
        if let list {
            return (try await convertListResultToData(list), list.pageToken)
            
        } else {
            return ([], nil)
        }
    }
    
    func fetchBackground(_ condition: String) async throws -> Data {
        return try await self.storageRef
            .child("background/\(condition).pdf")
            .data(maxSize: 1 * 1024 * 1024)
    }

    private func convertListResultToData(_ result: StorageListResult) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: Data.self, returning: [Data].self) { group in
            var dataList = [Data]()
            for item in result.items {
                if let cachedData = self.cacheManager.cachedResponse(for: item.fullPath) {
                    dataList.append(cachedData)
                }
                else {
                    group.addTask { [weak self] in
                        let data = try await item.data(maxSize: 1 * 1024 * 1024)
                        self?.cacheManager.setCache(for: item.fullPath, data: data)
                        return data
                    }
                }
            }
            for try await data in group {
                dataList.append(data)
            }
            return dataList
        }
    }
}
