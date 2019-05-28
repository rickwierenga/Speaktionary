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
    // MARK: - Private Variables
    private struct NetworkingConstants {
        static let key = "89c4577f743ced6ed32ce6da1b86da4e"
        static let appID = "d556f7cd"
        static let baseURL = "https://od-api.oxforddictionaries.com/api/v1"
        static let language = "en"
    }

    fileprivate var request: URLRequest {
        guard let entry = entry, !entry.utf8.isEmpty  else {
            fatalError("You must set an entry before fetching the defintion.")
        }

        let urlString = "https://od-api.oxforddictionaries.com:443/api/v1/entries/" +
        "\(NetworkingConstants.language)/\(entry.lowercased())"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NetworkingConstants.appID, forHTTPHeaderField: "app_id")
        request.addValue(NetworkingConstants.key, forHTTPHeaderField: "app_key")
        return request
    }

    // MARK: - Public API

    /// Fetch the meaning of the current entry. You must assign the entry first.
    ///
    /// - Parameter completion: A closure that will be called upon completionl
    public func fetchMeaning(_ completion: @escaping (String) -> Void) {
        // create a urlsession and start it.
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, _, error in
            if let data = data {
                // The data was succesfully loaded. Now extract the desired values from it.
                if let results = try? JSON(data: data)["results"].arrayValue {
                    let entries = results[0]["lexicalEntries"].arrayValue[0]["entries"].arrayValue
                    let senses = entries[0]["senses"].arrayValue
                    let definitions = senses[0]["definitions"].arrayValue
                    let definition = definitions[0].stringValue

                    // Set the definition of self on the main thread.
                    DispatchQueue.main.async {
                        self.definition = definition
                        completion(definition)
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    // the word could not be fetched
                    self.definition = error.localizedDescription
                    completion(error.localizedDescription)
                }
            } else {
                DispatchQueue.main.async {
                    self.definition = "not found"
                    completion("not found")
                }
            }
        }).resume()
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
