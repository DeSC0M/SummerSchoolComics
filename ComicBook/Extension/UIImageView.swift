//
//  LoadImage.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(by stringImage: String) {
        let url = URL(string: stringImage)!
        let data = try! Data(contentsOf: url)
        DispatchQueue.main.async {
            self.image = UIImage(data: data)
        }
    }
}
