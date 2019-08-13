//
//  BaseServices.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import Foundation

struct BaseServices {
    
    func getPhotos (
        onComplited: @escaping (ComicsEntry) -> Void,
        onError: @escaping (Error) -> Void
        ) {
        let url = URL(string: "\(NetworkConst.url)/\(Int.random(in: 0...2000))/info.0.json")!
        let task = URLSession.shared.dataTask(with: url) { (data, respons, error) in
            if let error = error {
                onError(error)
                return
            }
            
            guard
                let data = data,
                let photos = try? JSONDecoder().decode(ComicsEntry.self, from: data)
                else {
                    print("undable decode data")
                    return
            }
            
            // возвращаем фотографию и текст, который прилагается к фотографии (если имеется)
            onComplited(photos)
        }
        
        task.resume()
    }
    
}
