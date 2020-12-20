//
//  MainViewController.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, AlertCreator {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: UsersViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        viewModel = UsersViewModel(delegate: self)
        viewModel.loadUsers()
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.currentCount { //last row with indicator
            viewModel.loadUsers()
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentCount + 1 // for indicator row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.CellIdentifier, for: indexPath) as! UsersTableViewCell

        // if this is the last extra row
        if indexPath.row == viewModel.currentCount {
            cell.configure(with: .none)
        } else {
            let user = viewModel.user(at: indexPath.row)
            cell.configure(with: user)
        }
        return cell
    }
}

extension MainViewController: UsersViewModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        tableView.reloadData() // TODO reload rows
        viewModel.loadImages(forUsersAtIndexPaths: newIndexPathsToReload!)
    }

    func onImageReady(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func onFetchFailed(with reason: String) {
        let title = "Warning"
        // TODO retryAction
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        showAlert(with: title , message: reason, actions: [dismissAction])
    }
}
