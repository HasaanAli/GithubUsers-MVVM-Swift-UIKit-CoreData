//
//  AlertCreator.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol AlertCreator {
    func showAlert(with title: String, message: String, actions: [UIAlertAction]?)
}

extension AlertCreator where Self: UIViewController {
    func showAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController == nil else {
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
}
