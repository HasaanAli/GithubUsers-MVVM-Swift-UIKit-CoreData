//
//  User.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation

struct User: Decodable {
    let displayName: String
    let reputation: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case reputation
    }
    
    init(displayName: String, reputation: String) {
        self.displayName = displayName
        self.reputation = reputation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let displayName = try container.decode(String.self, forKey: .displayName)
        let reputation = try container.decode(Double.self, forKey: .reputation)
        self.init(displayName: displayName, reputation: String(reputation))
    }
}
