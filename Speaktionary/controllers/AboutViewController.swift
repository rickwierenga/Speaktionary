//
//  AboutViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Constants
    private let githubURL = URL(string: "https://github.com/rickwierenga/speaktionary")!
    private let swiftyJSONURL = URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!
    private let oxfordURL = URL(string: "https://developer.oxforddictionaries.com")!

    // MARK: - IBActions
    @IBAction func github() {
        UIApplication.shared.open(githubURL, options: [:], completionHandler: nil)
    }

    @IBAction func oxford() {
        UIApplication.shared.open(oxfordURL, options: [:], completionHandler: nil)
    }

    @IBAction func swiftyJSON() {
        UIApplication.shared.open(swiftyJSONURL, options: [:], completionHandler: nil)
    }
}
