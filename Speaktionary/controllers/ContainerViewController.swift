//
//  ContainerViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    enum Item: String {
        case record = "RecordViewController"
        case saved = "SavedViewController"
        case about = "AboutViewController"
    }

    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainContainerView: UIView!

    private var sideMenuOpen = false

    override func viewDidLoad() {
        // The default view controller is the recording view controller. Show it.
        showVC(.record)
    }

    @IBAction public func toggleSideMenu() {
        sideMenuConstraint.constant = sideMenuOpen ? -240.0 : 0
        sideMenuOpen = !sideMenuOpen
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.view.layoutIfNeeded()
        })
    }

    public func showVC(_ item: Item) {
        guard let navigationController = children[1] as? UINavigationController else { return }

        // get new view controller.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: item.rawValue)

        // Set the new view controller as the new child.
        navigationController.viewControllers = [viewController]
        navigationController.popToRootViewController(animated: false)
    }
}
