//
//  Image+CoreDataProperties.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 15/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var img: String?
    @NSManaged public var transcription: String?

}
