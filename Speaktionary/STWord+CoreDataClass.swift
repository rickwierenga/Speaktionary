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
        static let KEY = "89c4577f743ced6ed32ce6da1b86da4e"
        static let APP_ID = "d556f7cd"
        static let BASE_URL = "https://od-api.oxforddictionaries.com/api/v1"
        static let LANGUAGE = "en"
    }
    
    // MARK: - Public API
    
    /// Fetch the meaning of the current entry. You must assign the entry first.
    ///
    /// - Parameter completion: A closure that will be called upon completionl
    public func fetchMeaning(_ completion: @escaping (String) -> Void) {
        // make sure entry is not nil
        guard let entry = entry,  entry != ""  else {
            fatalError("You must set an entry before fetching the defintion.")
        }
        
        // set up a url request
        var request = URLRequest(url: URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(NetworkingConstants.LANGUAGE)/\(entry.lowercased())")!)
        
        // add the required fields
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(NetworkingConstants.APP_ID, forHTTPHeaderField: "app_id")
        request.addValue(NetworkingConstants.KEY, forHTTPHeaderField: "app_key")
        
        // create a urlsession and start it.
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                // data is succesfully fetched
                // load the definition from the json
                if let definition = try? JSON(data: data)["results"].arrayValue[0]["lexicalEntries"].arrayValue[0]["entries"].arrayValue[0]["senses"].arrayValue[0]["definitions"].arrayValue[0].stringValue {
                    // set the definition of self on the main thread
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
