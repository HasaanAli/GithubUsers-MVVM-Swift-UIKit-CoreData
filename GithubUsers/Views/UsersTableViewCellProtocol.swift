//
//  UserCellProtocol.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserProtocol {
    var id: Int { get }
}

protocol UserCellViewModelProtocol {
    var userP: UserProtocol { get }
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
}

class DefaultUserViewModel: UserCellViewModelProtocol {
    /// Of type UserProtocol
    let userP: UserProtocol

    init(user: User) {
        self.userP = user
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.CellIdentifier, for: indexPath) as! UsersTableViewCell
        cell.configure(with: userP as? User)
        return cell
    }
}

//TODO
//class InvertedUserCellViewModel: UserCellViewModelProtocol {
//
//}

