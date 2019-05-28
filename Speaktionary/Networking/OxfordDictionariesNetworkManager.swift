//
//  OxfordDictionariesNetworkManager.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 28/05/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import Foundation

class OxfordDictionariesNetworkManager {
    enum Result {
        case definitions([String])
        case error(Error)
        case notFound
    }

    private struct NetworkingConstants {
        static let key = "89c4577f743ced6ed32ce6da1b86da4e"
        static let appID = "d556f7cd"
        static let baseURL = "https://od-api.oxforddictionaries.com/api/v1"
        static let language = "en"
    }

     private static func urlRequest(for entry: String) -> URLRequest {
        guard !entry.utf8.isEmpty else {
            fatalError("Entries cannot be empty.")
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

    /// Fetch the meaning of an entry from the Oxford Dictionaries API.
    ///
    /// - Parameter completion: A closure that will be called upon completionl
    public static func fetchMeaning(entry: String, _ completion: @escaping (Result) -> Void) {
        let request = urlRequest(for: entry)
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, _, error in
            if let data = data {
                // The data was succesfully loaded. Now extract the desired values from it.
                var definitions = [String]()

                if let results = try? JSON(data: data)["results"].array,
                    let entries = results[0]["lexicalEntries"].arrayValue[0]["entries"].array,
                    let senses = entries[0]["senses"].array {

                    // First get the most usual definition
                    if let definition = senses[0]["definitions"].array?[0].string {
                        definitions.append(definition)
                    }

                    // Then get the other definitions
                    if let subsesnses = senses[0]["subsenses"].array {
                        let subDefinitions = subsesnses.compactMap({ $0["definitions"][0].string })
                        subDefinitions.forEach({ definitions.append($0) })
                    }
                }

                // Call completition on the main thread if the definitions were found, else use not found.
                if definitions.isEmpty {
                    DispatchQueue.main.async {
                        completion(.notFound)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.definitions(definitions))
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.notFound)
                }
            }
        }).resume()
    }
}
