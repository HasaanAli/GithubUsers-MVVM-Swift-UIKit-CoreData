//
//  InvertedUserCellViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class InvertedUserCellViewModel: UserCellViewModelProtocol {
    var userp: UserProtocol
    let unfilteredIndex: Int

    init(invertedUser: InvertedUser, unfilteredIndex: Int) {
        self.userp = invertedUser
        self.unfilteredIndex = unfilteredIndex
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvertedUserTableViewCell.CellIdentifier, for: indexPath) as! InvertedUserTableViewCell
        cell.configure(with: userp)
        return cell
    }
}
