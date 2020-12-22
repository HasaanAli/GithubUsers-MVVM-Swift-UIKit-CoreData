//
//  DefaultUserCellViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class DefaultUserCellViewModel: UserCellViewModelProtocol {
    /// Of type UserProtocol
    var userP: UserProtocol

    init(user: User) {
        self.userP = user
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.CellIdentifier, for: indexPath) as! UsersTableViewCell
        cell.configure(with: userP)
        return cell
    }
}

//TODO
//class InvertedUserCellViewModel: UserCellViewModelProtocol {
//
//}
