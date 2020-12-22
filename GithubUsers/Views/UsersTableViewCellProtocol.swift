//
//  UserCellProtocol.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserTableViewCellProtocol {
    func configure(with userp: UserProtocol)
    func reset()
}
