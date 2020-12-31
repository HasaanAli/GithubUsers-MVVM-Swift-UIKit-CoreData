//
//  User.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

struct User: Decodable, UserProtocol, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    var image: UIImage? // initially nil, will be set outside

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
    }
    
    init(id: Int, login: String, avatarUrl: String, image: UIImage? = nil) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.image = image
    }

    init(notesUser: NotesUser) {
        self.id = notesUser.id
        self.login = notesUser.login
        self.avatarUrl = notesUser.avatarUrl
        self.image = notesUser.image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let login = try container.decode(String.self, forKey: .login)
        let avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.init(id: id, login: login, avatarUrl: avatarUrl)
    }
}
