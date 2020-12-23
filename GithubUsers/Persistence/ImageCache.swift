//
//  ImageCache.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/20/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol!

    static let sharedInstance = ImageCache()

    private init() {
        // make sure to purge cache on memory pressure
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(observer)
    }

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

//TODO: Make Codable
//    func saveToDisk( withName name: String,using fileManager: FileManager = .default) throws {
//        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
//
//        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
//        let data = try JSONEncoder().encode(cache)
//        try data.write(to: fileURL)
//    }
}
