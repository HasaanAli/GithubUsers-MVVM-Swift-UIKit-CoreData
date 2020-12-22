//
//  NotesUserCellViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

class NotesUserCellViewModel: UserCellViewModelProtocol {
    var userP: UserProtocol

    init(notesUser: NotesUser) {
        self.userP = notesUser
    }

    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotesUserTableViewCell.CellIdentifier, for: indexPath) as! NotesUserTableViewCell
        cell.configure(with: userP)
        return cell
    }
}
