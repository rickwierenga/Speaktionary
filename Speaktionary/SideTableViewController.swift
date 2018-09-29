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
        tableView.deselectRow(at: indexPath, animated: true)
        let identifier = (tableView.cellForRow(at: indexPath)?.textLabel?.text)! + "ViewController"
        (parent as! ContainerViewController).showVC(ContainerViewController.HamburgerItem(rawValue: identifier)!)
        (parent as! ContainerViewController).toggleSideMenu()
    }
}
