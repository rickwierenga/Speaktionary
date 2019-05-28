//
//  SideTableViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit

class SideTableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let parent = parent as? ContainerViewController else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        let identifier = (tableView.cellForRow(at: indexPath)?.textLabel?.text)! + "ViewController"
        parent.showVC(ContainerViewController.HamburgerItem(rawValue: identifier)!)
        parent.toggleSideMenu()
    }
}
