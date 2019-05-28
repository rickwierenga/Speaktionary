//
//  AboutViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    private let githubURL = URL(string: "https://github.com/rickwierenga/speaktionary")!
    private let swiftyJSONURL = URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!
    private let oxfordURL = URL(string: "https://developer.oxforddictionaries.com")!

    @IBAction func openGitub() { open(url: githubURL) }
    @IBAction func openSwiftyJSON() { open(url: swiftyJSONURL) }
    @IBAction func openOxford() { open(url: oxfordURL) }

    private func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
