//
//  ImageCacheManager.swift
//  GitHubSearcher
//
//  Created by Peter on 4/19/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import Foundation
import UIKit

class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    var imageCached = NSCache<NSString, NSData>()
    
    private init() { }
    
    /// Get image from cache with url
    /// - Parameters:
    ///   - urlString:The url in String type
    func getImageForUrl(urlString: String) -> NSData? {
        guard let cachedData = imageCached.object(forKey: NSString(string: urlString)) else {
            return nil
        }
        return cachedData
    }
    
    /// Get image from cache with url
    /// - Parameters:
    ///   - urlString:The url in String type
    ///   - data: The data to insert to Cache
    func setImageForUrl(urlString: String, data: NSData) {
        imageCached.setObject(data, forKey: NSString(string: urlString))
    }
}
