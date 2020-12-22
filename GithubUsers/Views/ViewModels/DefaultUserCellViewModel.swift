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
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultUserTableViewCell.CellIdentifier, for: indexPath) as! DefaultUserTableViewCell
        cell.configure(with: userP)
        return cell
    }
}
