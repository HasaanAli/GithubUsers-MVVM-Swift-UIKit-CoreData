//
//  UsersViewController.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, AlertCreator {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    /// View controller's view model.
    private var vcViewModel: UsersViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.showsCancelButton = true

        // Register non-default cell classes
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.CellIdentifier)

        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        vcViewModel = UsersViewModel(delegate: self, apiPageSize: 100)
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == vcViewModel.currentCount { //last row with indicator
            vcViewModel.loadData()
        }
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcViewModel.currentCount + 1 // for activity indicator row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // LoadingTableViewCell doesn't conform to UsersTableViewCellProtocol, because it only has a UIActivityIndicator

        if indexPath.row == vcViewModel.currentCount { // if its the activity indicator row
            return tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.CellIdentifier, for: indexPath) as! LoadingTableViewCell
        } else {
            let cellViewModel = vcViewModel.cellViewModel(at: indexPath.row)
            return cellViewModel.cellForTableView(tableView: tableView, atIndexPath: indexPath)
        }
    }
}

extension UsersViewController: UsersViewModelDelegate {
    func onFetchFromDBCompleted() {
        tableView.reloadData()
        //TODO: check & fetch missing db images
    }

    func onFetchFromApiCompleted(with newIndexPathsToReload: [IndexPath]?) {
        if let newIndexPathsToReload = newIndexPathsToReload {
//            tableView.reloadRows(at: newIndexPathsToReload, with: .automatic)
            tableView.reloadData()
            vcViewModel.downloadImages(forUsersAtIndexPaths: newIndexPathsToReload)
        } else {
            tableView.reloadData()
            //TODO viewModel.loadImagesFromCacheThenApi
        }
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

extension UsersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        super
//        viewModel.filterData(by: searchText)
//    }
}
