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
   
    private func convertListResultToURLs(_ result: StorageListResult) async throws -> [URL] {
        return try await withThrowingTaskGroup(of: URL.self, returning: [URL].self) { group in
            for item in result.items {
                group.addTask {
                    try await item.downloadURL()
                }
            }
            var urls = [URL]()
            for try await url in group {
                urls.append(url)
            }
            return urls
        }
    }
    
    private func convertListResultToData(_ result: StorageListResult) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: Data.self, returning: [Data].self) { group in
            for item in result.items {
                group.addTask {
                    try await item.data(maxSize: 1 * 1024 * 1024)
                }
            }
            var dataList = [Data]()
            for try await data in group {
                dataList.append(data)
            }
            return dataList
        }
    }
}
