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
        let cell = tableView.cellForRow(at: indexPath)!
        let identifier = cell.textLabel!.text! + "ViewController"
        parent.showVC(ContainerViewController.Item(rawValue: identifier)!)
        parent.toggleSideMenu()
    }
}
