//
//  AppDelegate.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 23/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SavedWords")

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }()

    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
}
