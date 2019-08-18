//
//  LoadImage.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(by urlImage: String) {

        let cache = URLCache.shared
        
        guard let url = URL(string: urlImage) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        if let data = cache.cachedResponse(for: request)?.data {
            // данные есть на диске
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        } else {
            // данных нет на диске
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("error with data: \(error)")
                    return
                }
                
                if
                    let data = data,
                    let response = response
                {
                    let cacheData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cacheData, for: request)
                    DispatchQueue.main.async { //async
                        self.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
