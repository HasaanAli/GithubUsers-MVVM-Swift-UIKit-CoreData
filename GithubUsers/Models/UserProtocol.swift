//
//  UserProtocol.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UserProtocol {
    var id: Int { get }
    var login: String  { get }
    var avatarUrl: String  { get }
    var image: UIImage? { get set }
}
