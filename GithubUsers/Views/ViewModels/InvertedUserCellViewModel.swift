//
//  InvertedUserCellViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class InvertedUserCellViewModel: UserCellViewModelProtocol {
    var userP: UserProtocol

    init(invertedUser: InvertedUser) {
        self.userP = invertedUser
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvertedNotesUserTableViewCell.CellIdentifier, for: indexPath) as! InvertedNotesUserTableViewCell
        cell.configure(with: userP)
        return cell
    }
}
