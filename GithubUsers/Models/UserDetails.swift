//
//  UserDetails.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

struct UserDetails: Decodable, UserProtocol {
    let id: Int
    let login: String
    let avatarUrl: String
    var notes: String = ""
    var image: UIImage? = nil
    var followers: Int? = nil
    var following: Int? = nil

    var bio: String { //TODO use more properties
        return "name: \n company: \n"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case followers
        case following
    }

    init(id: Int, login: String, avatarUrl: String) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let login = try container.decode(String.self, forKey: .login)
        let avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.init(id: id, login: login, avatarUrl: avatarUrl)

        self.followers = try container.decode(Int.self, forKey: .followers)
        self.following = try container.decode(Int.self, forKey: .following)
    }
}
