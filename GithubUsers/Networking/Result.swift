//
//  UserResponse.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}
