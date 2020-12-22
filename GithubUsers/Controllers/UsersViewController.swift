//
//  UsersViewController.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, AlertCreator {
    let tag2 = "UsersViewController -"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    /// View controller's view model.
    private var viewModel: UsersViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.showsCancelButton = true

        // Register non-storyboard cell classes
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.CellIdentifier)

        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        viewModel = UsersViewModel(delegate: self, apiPageSize: 100)
    }
}

extension UsersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let svcIdentifier = "UserDetailsViewController"
        guard let detailViewController = storyBoard.instantiateViewController(withIdentifier: svcIdentifier)
            as? UserDetailsViewController  else {
                NSLog("%@ Cannot get VC with identifier %@", tag2, svcIdentifier)
                return
        }
        let userp = viewModel.cellViewModel(at: indexPath.row).userP
        detailViewController.viewModel = UserDetailsViewModel(userp: userp, at: indexPath, delegate: detailViewController)
        detailViewController.notesDelegate = self
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.currentCount { // last row with indicator
            viewModel.loadData()
        }
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentCount + 1 // for activity indicator row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // LoadingTableViewCell doesn't conform to UsersTableViewCellProtocol, because it only has a UIActivityIndicator

        if indexPath.row == viewModel.currentCount { // if its the activity indicator row
            return tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.CellIdentifier, for: indexPath) as! LoadingTableViewCell
        } else {
            let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
            return cellViewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath)
        }
    }
}

extension UsersViewController: UsersViewModelDelegate {
    func onCellViewModelsChanged() {
        tableView.reloadData()
    }

    func onCellViewModelsUpdated(at indexPaths: [IndexPath]) {
        tableView.reloadData()
        // tableView.cellForRow(at: ind)
        // TODO begin and end updates
        // tableView.reloadRows(at: indexPaths, with: .automatic)
    }

    func onLoadFailed(with reason: String) {
        NSLog("%@ onLoadFailed(with reason:) - \(reason)", tag2)
        //        let title = "Warning"
        //        // TODO retryAction
        //        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        //        showAlert(with: title , message: reason, actions: [dismissAction])
    }

    func onImageReady(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension UsersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        super
//        viewModel.filterData(by: searchText)
//    }
}

extension UsersViewController: UserDetailsNotesDelegate {
    func onNotesUpdated(notes: String, at indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            NSLog("%@ onNotesUpdates Got indexPath = nil", tag2)
            return
        }
        viewModel.updateCellViewModel(with: notes, at: indexPath)
    }
}
