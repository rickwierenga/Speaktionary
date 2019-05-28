//
//  STWord+CoreDataProperties.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//
//

import Foundation
import CoreData

extension STWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<STWord> {
        return NSFetchRequest<STWord>(entityName: "STWord")
    }

    @NSManaged public var entry: String?
    @NSManaged public var definition: String?

}
