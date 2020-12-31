//
//  InvertedUser.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/22/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

struct InvertedUser: UserProtocol, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    var image: UIImage?
    var notes: String = ""

    var invertedImage: UIImage? {
        // TODO should cache inverted image?
        return image == nil ? nil : ImageUtilities.invert(image: image!)
    }

    init(id: Int, login: String, avatarUrl: String, image: UIImage? = nil, notes: String = "") {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.image = image
        self.notes = notes
    }
}
