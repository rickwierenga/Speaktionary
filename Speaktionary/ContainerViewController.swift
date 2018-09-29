//
//  ContainerViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK : - Data types
    enum HamburgerItem: String {
        case record = "RecordViewController"
        case saved = "SavedViewController"
        case about = "AboutViewController"
    }
    
    // MARK: - Private properties
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainContainerView: UIView!
    private var sideMenuOpen = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        showVC(.saved) // default is record
    }
    
    // MARK: - Public API
    
    @IBAction public func toggleSideMenu() {
        sideMenuConstraint.constant = sideMenuOpen ? -240.0 : 0
        sideMenuOpen = !sideMenuOpen
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }
    
    public func showVC(_ item: HamburgerItem) {
        let navigationController = children[1] as! UINavigationController
        
        // get new view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: item.rawValue)
        
        // set the new view controller as the new child
        navigationController.viewControllers = [viewController]
        navigationController.popToRootViewController(animated: false)
    }
}
