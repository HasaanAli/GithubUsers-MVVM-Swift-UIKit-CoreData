//
//  Int+isForth.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/23/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

extension Int {
    /// To be used for checking Inverted users.
    var isForth: Bool {
        return self % 4 == 3
    }
}
