//
//  STWord+CoreDataProperties.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 28/05/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//
//

import Foundation
import CoreData

extension STWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STWord> {
        return NSFetchRequest<STWord>(entityName: "STWord")
    }

    @NSManaged public var definitions: [String]?
    @NSManaged public var entry: String?

}
