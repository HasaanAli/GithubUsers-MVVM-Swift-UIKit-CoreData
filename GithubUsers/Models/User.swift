//
//  User.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: Int
    let login: String
    let avatarUrl: String
    let notes: String // Empty string = No notes, local property, not in Api

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
    }
    
    init(id: Int, login: String, avatarUrl: String, notes: String = "") {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let login = try container.decode(String.self, forKey: .login)
        let avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.init(id: id, login: login, avatarUrl: avatarUrl)
    }
}
