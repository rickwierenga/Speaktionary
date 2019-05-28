//
//  UIViewController+ShowAlert.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 28/05/2019.
//  Copyright © 2019 Rick Wierenga. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
