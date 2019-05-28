//
//  STWord+CoreDataClass.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//
//

import Foundation
import CoreData

/// A class that manages a word and the accompanying defition.
@objc(STWord)
public class STWord: NSManagedObject {
    func getDefinition(_ completion: @escaping (OxfordDictionariesNetworkManager.Result) -> Void) {
        guard let entry = entry, !entry.utf8.isEmpty else { fatalError("This word has not entry") }
        OxfordDictionariesNetworkManager.fetchMeaning(entry: entry) { result in
            switch result {
            case let .definitions(definitions):
                self.definitions = definitions
            default:
                self.definitions = []
            }
            completion(result)
        }
    }

    func definitionString() -> String {
        return self.definitions?.joined(separator: "\n\n") ?? "No definitions saved"
    }

    // MARK: - Initializers
    public init(entry: String, entity: NSEntityDescription, insertInto context: NSManagedObjectContext) {
        super.init(entity: entity, insertInto: context)
        self.entry = entry
    }

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
