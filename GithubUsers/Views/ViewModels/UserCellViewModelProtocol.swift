//
//  UserCellViewModelProtocol.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserCellViewModelProtocol {
    // If user taps filtered table row, and update notes, this index makes possible to update cellViewModel at
    // original/unfiltered array index.
    var unfilteredIndex: Int  { get }
    var userp: UserProtocol { get set }
    func cellForTableView(tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
}
