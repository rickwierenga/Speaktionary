//
//  SavedTableViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 29/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit
import CoreData

class SavedTableViewController: UITableViewController {
    // MARK: - Private properties
    private lazy var fetchRequest: NSFetchRequest<STWord> = {
        let fetchRequest = NSFetchRequest<STWord>(entityName: "STWord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "entry", ascending: true)]
        return fetchRequest
    }()
    private lazy var managedContext: NSManagedObjectContext = {
        // swiftlint:disable force_cast
        return (UIApplication.shared.delegate as! AppDelegate).managedContext
    }()
    private lazy var fetchedResultsContorller: NSFetchedResultsController<STWord> = {
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: managedContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: "SavedWords")
    }()

    let showWordSegueIdentifier = "ShowWord"

    // MARK: - Helpers
    private func fetch() {
        do {
            try fetchedResultsContorller.performFetch()
        } catch let error as NSError {
            let alertController = UIAlertController(title: "Error fetching words",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)

            print(error)
        }
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        self.fetch()
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved Words"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsContorller.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = fetchedResultsContorller.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCell", for: indexPath)

        cell.textLabel?.text = word.entry!

        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let word = fetchedResultsContorller.object(at: indexPath)
            managedContext.delete(word)

            do {
                try managedContext.save()
                self.fetch()
                self.tableView.reloadData()
            } catch let error as NSError {
                let alertController = UIAlertController(title: "Error deleting word",
                                           message: error.localizedDescription,
                                           preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true)

                print(error)
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showWordSegueIdentifier, sender: indexPath)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showWordSegueIdentifier:
            guard let viewController = segue.destination as? ViewController else { fatalError() }
            viewController.word = fetchedResultsContorller.object(at: sender as! IndexPath)
        default:
            break
        }
    }
}
